extends Node3D

# Variables para configurar el lanzamiento de bolas de fuego
var fireball_scene = preload("res://Scenes/meteors.tscn")  # Escena de la bola de fuego
var launch_interval = 5  # Intervalo de lanzamiento en segundos
var launch_force = 5000  # Fuerza de lanzamiento de la bola de fuego
var launch_radius = 10
var Lava_Level  = 125

@onready var skeleton = $Volcano/ref_skeleton/Skeleton3D

func _ready():
	_launch_fireball()

func _process(_delta: float) -> void:
	set_lava_level(230)

func set_lava_level(lvl: float) -> void:
	var lava_lvl = clamp(lvl, 0, 250)

	if lava_lvl <= 100:
		skeleton.set_bone_pose_position(skeleton.find_bone("lava_level"), Vector3(0, lava_lvl, 0))
		skeleton.set_bone_pose_position(skeleton.find_bone("lava_level_extension"), Vector3(0, 0, 0))
		skeleton.set_bone_pose_position(skeleton.find_bone("lava_level_extension_02"),  Vector3(0, 0, 0))
	elif lava_lvl > 100 and lava_lvl < 200:
		var diff = lava_lvl - 100
		skeleton.set_bone_pose_position(skeleton.find_bone("lava_level"), Vector3(0, 100, 0))
		skeleton.set_bone_pose_position(skeleton.find_bone("lava_level_extension"),Vector3(0, 0, diff))
		skeleton.set_bone_pose_position(skeleton.find_bone("lava_level_extension_02"), Vector3(0, 0, 0))
	elif lava_lvl >= 200 and lava_lvl <= 300:
		var diff = lava_lvl - 200
		skeleton.set_bone_pose_position(skeleton.find_bone("lava_level"), Vector3(0, 100, 0))
		skeleton.set_bone_pose_position(skeleton.find_bone("lava_level_extension"),  Vector3(0, 0, 100))
		skeleton.set_bone_pose_position(skeleton.find_bone("lava_level_extension_02"), Vector3(0, 0, diff))

	self.Lava_Level = lava_lvl


func GetLavaLevelPosition():
	return skeleton.get_bone_pose_position(skeleton.find_bone("lava_level"))

func _launch_fireball():
	# Instanciar una nueva bola de fuego y lanzarla
	var fireball = fireball_scene.instantiate()
	var launch_direction = Vector3(randi_range(-1,1), 1, randi_range(-1,1)).normalized()  # Dirección hacia arriba
	fireball.global_position = GetLavaLevelPosition() # Posición inicial en el volcán
	fireball.scale = Vector3(1,1,1)
	fireball.is_volcano_rock = true
	fireball.apply_impulse(GetLavaLevelPosition(), launch_direction * launch_force)  # Aplicar fuerza para lanzar la bola de fuego
	add_child(fireball, true)  # Agregar la bola de fuego como hijo del volcán

	await get_tree().create_timer(launch_interval).timeout
	_launch_fireball()

func _on_area_3d_body_entered(body:Node3D) -> void:
	if body.is_in_group("player"):
		body.IsInLava = true

		if body.camera_node:
			body.IsUnderLava = true


func _on_area_3d_body_exited(body:Node3D) -> void:
	if body.is_in_group("player"):
		body.IsInLava = false

		if body.camera_node:
			body.IsUnderLava = false
