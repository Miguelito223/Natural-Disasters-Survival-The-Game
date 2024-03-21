extends RigidBody3D

var explosion_scene = preload("res://Scenes/explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.scale = Vector3(randf_range(1,100),randf_range(1,100),randf_range(1,100))
	self.mass = 1
	self.gravity_scale = Globals.gravity
	$CollisionShape3D.scale = self.scale


func explosion():
	var explosion_node = explosion_scene.instantiate()
	explosion_node.position = self.position
	explosion_node.emitting = true
	get_parent().add_child(explosion_node)
	self.queue_free()
	
	await explosion_node.finished
	explosion_node.queue_free()


func _on_body_entered(_body):
	explosion()
