extends Node3D

var player_scene = preload("res://Scenes/player.tscn")

var current_weather_and_disaster = "Sun"
var current_weather_and_disaster_int = "Sun"

var linghting_scene = preload("res://Scenes/linghting.tscn")
var meteor_scene = preload("res://Scenes/meteors.tscn")

var noise = FastNoiseLite.new()
var noise_seed

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Globals.is_networking:
		$Timer.wait_time = Globals.timer
		generate_seed()
		receive_seeds(noise_seed)
	else:

		get_tree().get_multiplayer().peer_connected.connect(player_join)
		get_tree().get_multiplayer().peer_disconnected.connect(player_disconect)
		get_tree().get_multiplayer().server_disconnected.connect(server_disconect)
		get_tree().get_multiplayer().connected_to_server.connect(server_connected)
		get_tree().get_multiplayer().connection_failed.connect(server_fail)

		if not OS.has_feature("dedicated_server") and get_tree().get_multiplayer().is_server():
			player_join(1)

		if get_tree().get_multiplayer().is_server():
			generate_seed()

		$Timer.wait_time = Globals.timer


func generate_seed():
	noise_seed = randi()

@rpc("call_local", "any_peer")
func receive_seeds(received_noise_seed):
	print("recibiendo semillas...")
	noise_seed = received_noise_seed
	generate_terrain()

func generate_terrain():
	print("Generating world...")

	var terrain = Terrain3D.new()
	terrain.set_collision_enabled(false)
	terrain.storage = Terrain3DStorage.new()
	terrain.texture_list = Terrain3DTextureList.new()
	add_child(terrain, true)
	terrain.material.world_background = Terrain3DMaterial.NOISE
	var texture = Terrain3DTexture.new()
	var image = load("res://Textures/leafy_grass_diff_4k.jpg")
	texture.name = "Grass"
	texture.texture_id = 0
	texture.albedo_texture = image
	terrain.texture_list.set_texture(texture.texture_id, texture)
	terrain.name = "Terrain3D"

	await get_tree().create_timer(2).timeout
	
	noise.frequency = 0.0005
	noise.seed = noise_seed
	var img = Image.create(2048, 2048, false, Image.FORMAT_RF)
	for x in 2048:
		for y in 2048:
			img.set_pixel(x,y, Color(noise.get_noise_2d(x,y) * 0.5, 0., 0., 1.))
	terrain.storage.import_images([img,null,null],  Vector3(0,0,0), 0.0, 300.)

	terrain.set_collision_enabled(true)


func _process(_delta):
	for i in get_child_count():
		var object = get_child(i)
		if object.get_class() == "CharacterBody3D":
			var Wind_Velocity = Globals.convert_MetoSU(Globals.convert_KMPHtoMe(Globals.Wind_speed / 2.9225)) * Globals.Wind_Direction
			var frictional_scalar = clamp(Wind_Velocity.length(), 0, object.mass)
			var frictional_velocity = frictional_scalar * -Wind_Velocity.normalized()
			var Wind_Velocity_new = (Wind_Velocity + frictional_velocity) * -1
			object.velocity =  Wind_Velocity_new
			object.move_and_slide()
		elif object.get_class() == "RigidBody3D":
			var Wind_Velocity = Globals.convert_MetoSU(Globals.convert_KMPHtoMe(Globals.Wind_speed / 2.9225)) * Globals.Wind_Direction
			var frictional_scalar = clamp(Wind_Velocity.length(), 0, object.mass)
			var frictional_velocity = frictional_scalar * -Wind_Velocity.normalized()
			var Wind_Velocity_new = (Wind_Velocity + frictional_velocity) * -1
			object.linear_velocity =  Wind_Velocity_new

	
	
func _on_timer_timeout():
	sync_weather_and_disaster()

func sync_weather_and_disaster():
	if Globals.is_networking:
		var random_weather_and_disaster = randi_range(0,10)
		set_weather_and_disaster.rpc(random_weather_and_disaster)
	else:
		var random_weather_and_disaster = randi_range(0,10)
		set_weather_and_disaster(random_weather_and_disaster)		

@rpc("any_peer", "call_local")
func set_weather_and_disaster(weather_and_disaster_index):
	match weather_and_disaster_index:
		0:
			current_weather_and_disaster = "Sun"
			current_weather_and_disaster_int = 0
			is_sun()
		1:
			current_weather_and_disaster = "Cloud"
			current_weather_and_disaster_int = 1
			is_cloud()
		2:
			current_weather_and_disaster = "Raining"
			current_weather_and_disaster_int = 2
			is_raining()
		3:
			current_weather_and_disaster = "storm"
			current_weather_and_disaster_int = 3
			is_storm()
		4:
			current_weather_and_disaster = "Linghting storm"
			current_weather_and_disaster_int = 4
			is_linghting_storm()

		5:
			current_weather_and_disaster = "Tsunami"
			current_weather_and_disaster_int = 5
			is_tsunami()

		6:
			current_weather_and_disaster = "Meteor shower"
			current_weather_and_disaster_int = 6
			is_meteor_shower()
		7:
			current_weather_and_disaster = "Volcano"
			current_weather_and_disaster_int = 7
			is_volcano()
		8:
			current_weather_and_disaster = "Tornado"
			current_weather_and_disaster_int = 8
			is_tornado()
		9:
			current_weather_and_disaster = "Acid rain"
			current_weather_and_disaster_int = 9
			is_acid_rain()
		10:
			current_weather_and_disaster = "Earthquake"
			current_weather_and_disaster_int = 10
			is_earthquake()

func is_tsunami():
	for i in get_child_count():
		var player = get_child(i)
		if player.is_in_group("player"):
			player.rain_node.emitting = false

	$WorldEnvironment.environment.volumetric_fog_enabled = false
	$WorldEnvironment.environment.volumetric_fog_albedo = Color(1,1,1)
	Globals.Temperature_target = randi_range(20,31)
	Globals.Humidity_target = randi_range(0,20)
	Globals.pressure_target = randi_range(10000,10020)
	Globals.Wind_Direction_target = Vector3(randi_range(-1,1),0,randi_range(-1,1))
	Globals.Wind_speed_target = randi_range(0, 10)

func is_linghting_storm():
	for i in get_child_count():
		var player = get_child(i)
		if player.is_in_group("player"):
			player.rain_node.emitting = true

	$WorldEnvironment.environment.volumetric_fog_enabled = true
	$WorldEnvironment.environment.volumetric_fog_albedo = Color(1,1,1)
	Globals.Temperature_target =  randi_range(5,15)
	Globals.Humidity_target = randi_range(30,40)
	Globals.pressure_target = randi_range(8000,9000)
	Globals.Wind_Direction_target =  Vector3(randi_range(-1,1),0,randi_range(-1,1))
	Globals.Wind_speed_target = randi_range(0, 30)

	for i in range(5000, 20000):
		var lighting = linghting_scene.instantiate()
		lighting.position = Vector3(randi_range(0,2048),0,randi_range(0,2048))
		add_child(lighting, true)
		if current_weather_and_disaster != "Linghting storm":
			break
		await get_tree().create_timer(5).timeout


func is_meteor_shower():
	for i in get_child_count():
		var player = get_child(i)
		if player.is_in_group("player"):
			player.rain_node.emitting = false

	Globals.Temperature_target = randi_range(20,31)
	Globals.Humidity_target = randi_range(0,20)
	Globals.pressure_target = randi_range(10000,10020)
	Globals.Wind_Direction_target = Vector3(randi_range(-1,1),0,randi_range(-1,1))
	Globals.Wind_speed_target = randi_range(0, 10)

	$WorldEnvironment.environment.volumetric_fog_enabled = false
	$WorldEnvironment.environment.volumetric_fog_albedo = Color(1,1,1)
	for i in range(5000, 20000):
		var meteor = meteor_scene.instantiate()
		meteor.position = Vector3(randi_range(0,2048),1000,randi_range(0,2048))
		add_child(meteor, true)
		if current_weather_and_disaster != "Meteor shower":
			break
		await get_tree().create_timer(5).timeout

func is_volcano():
	for i in get_child_count():
		var player = get_child(i)
		if player.is_in_group("player"):
			player.rain_node.emitting = false

	$WorldEnvironment.environment.volumetric_fog_enabled = false
	$WorldEnvironment.environment.volumetric_fog_albedo = Color(1,1,1)
	Globals.Temperature_target =  randi_range(30,40)
	Globals.Humidity_target = randi_range(0,10)
	Globals.pressure_target = randi_range(10000,10020)
	Globals.Wind_Direction_target =  Vector3(randi_range(-1,1),0,randi_range(-1,1))
	Globals.Wind_speed_target = randi_range(0, 50)

func is_tornado():
	for i in get_child_count():
		var player = get_child(i)
		if player.is_in_group("player"):
			player.rain_node.emitting = true
	
	$WorldEnvironment.environment.volumetric_fog_enabled = true
	$WorldEnvironment.environment.volumetric_fog_albedo = Color(1,1,1)
	Globals.Temperature_target =  randi_range(5,15)
	Globals.Humidity_target = randi_range(30,40)
	Globals.pressure_target = randi_range(8000,9000)
	Globals.Wind_Direction_target =  Vector3(randi_range(-1,1),0,randi_range(-1,1))
	Globals.Wind_speed_target = randi_range(0, 30)

	for i in range(5000, 20000):
		var lighting = linghting_scene.instantiate()
		lighting.position = Vector3(randi_range(0,2048),0,randi_range(0,2048))
		add_child(lighting, true)
		if current_weather_and_disaster != "Linghting storm":
			break
		await get_tree().create_timer(5).timeout

func is_acid_rain():
	for i in get_child_count():
		var player = get_child(i)
		if player.is_in_group("player"):
			player.rain_node.emitting = true

	$WorldEnvironment.environment.volumetric_fog_enabled = true
	$WorldEnvironment.environment.volumetric_fog_albedo = Color(0,1,0)
	Globals.Temperature_target = randi_range(20,31)
	Globals.Humidity_target = randi_range(0,20)
	Globals.pressure_target = randi_range(10000,10020)
	Globals.Wind_Direction_target = Vector3(randi_range(-1,1),0,randi_range(-1,1))
	Globals.Wind_speed_target = randi_range(0, 10)

func is_earthquake():
	for i in get_child_count():
		var player = get_child(i)
		if player.is_in_group("player"):
			player.rain_node.emitting = false

	$WorldEnvironment.environment.volumetric_fog_enabled = false
	$WorldEnvironment.environment.volumetric_fog_albedo = Color(1,1,1)
	Globals.Temperature_target = randi_range(20,31)
	Globals.Humidity_target = randi_range(0,20)
	Globals.pressure_target = randi_range(10000,10020)
	Globals.Wind_Direction_target = Vector3(randi_range(-1,1),0,randi_range(-1,1))
	Globals.Wind_speed_target = randi_range(0, 10)


func is_sun():
	for i in get_child_count():
		var player = get_child(i)
		if player.is_in_group("player"):
			player.rain_node.emitting = false
	
	$WorldEnvironment.environment.volumetric_fog_enabled = false
	$WorldEnvironment.environment.volumetric_fog_albedo = Color(1,1,1)
	Globals.Temperature_target = randi_range(20,31)
	Globals.Humidity_target = randi_range(0,20)
	Globals.pressure_target = randi_range(10000,10020)
	Globals.Wind_Direction_target = Vector3(randi_range(-1,1),0,randi_range(-1,1))
	Globals.Wind_speed_target = randi_range(0, 10)

func is_cloud():
	for i in get_child_count():
		var player = get_child(i)
		if player.is_in_group("player"):
			player.rain_node.emitting = false

	$WorldEnvironment.environment.volumetric_fog_enabled = true
	$WorldEnvironment.environment.volumetric_fog_albedo = Color(1,1,1)
	Globals.Temperature_target =  randi_range(20,25)
	Globals.Humidity_target = randi_range(10,30)
	Globals.pressure_target = randi_range(9000,10000)
	Globals.Wind_Direction_target = Vector3(randi_range(-1,1),0,randi_range(-1,1))
	Globals.Wind_speed_target =  randi_range(0, 10)

func is_raining():
	for i in get_child_count():
		var player = get_child(i)
		if player.is_in_group("player"):
			player.rain_node.emitting = true

	$WorldEnvironment.environment.volumetric_fog_enabled = true
	$WorldEnvironment.environment.volumetric_fog_albedo = Color(1,1,1)
	Globals.Temperature_target =   randi_range(10,20)
	Globals.Humidity_target =  randi_range(20,40)
	Globals.pressure_target = randi_range(9000,9020)
	Globals.Wind_Direction_target =  Vector3(randi_range(-1,1),0,randi_range(-1,1))
	Globals.Wind_speed_target = randi_range(0, 20)

func is_storm():
	for i in get_child_count():
		var player = get_child(i)
		if player.is_in_group("player"):
			player.rain_node.emitting = true

	$WorldEnvironment.environment.volumetric_fog_enabled = true
	$WorldEnvironment.environment.volumetric_fog_albedo = Color(1,1,1)
	Globals.Temperature_target =  randi_range(5,15)
	Globals.Humidity_target = randi_range(30,40)
	Globals.pressure_target = randi_range(8000,9000)
	Globals.Wind_Direction_target =  Vector3(randi_range(-1,1),0,randi_range(-1,1))
	Globals.Wind_speed_target = randi_range(0, 30)


func player_join(id):
	print("Joined player id: " + str(id))
	var player = player_scene.instantiate()
	player.id = id
	player.name = str(id)
	Globals.players_conected_array.append(player)
	Globals.players_conected_int = Globals.players_conected_array.size() - 1
	add_child(player,true)

	if get_tree().get_multiplayer().is_server():
		receive_seeds.rpc(noise_seed)

func player_disconect(id):
	print("Disconected player id: " + str(id))
	var player = get_node(str(id))
	if is_instance_valid(player):
		Globals.players_conected_array.erase(player)
		Globals.players_conected_int = Globals.players_conected_array.size() - 1
		player.queue_free()

func server_disconect():
	Globals.Temperature_target = Globals.Temperature_original
	Globals.Humidity_target = Globals.Humidity_original
	Globals.pressure_target = Globals.pressure_original
	Globals.Wind_Direction_target = Globals.Wind_Direction_original
	Globals.Wind_speed_target = Globals.Wind_speed_original
	Globals.players_conected_array.clear()
	Globals.players_conected_int = Globals.players_conected_array.size() - 1
	self.queue_free()
	get_parent().get_node("Main Menu").show()


func server_fail():
	get_parent().get_node("Main Menu").show()


func server_connected():
	print("connected to server :)")
