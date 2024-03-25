extends CharacterBody3D
var speed = 5000
var move_speed = 100
var direction = Vector3(0,0,1)

func _physics_process(delta):
	self.velocity = direction * speed * delta
	move_and_slide()

func _on_area_3d_body_entered(body:Node3D):
	if body.is_in_group("player"):
		body.IsInWater = true
		body.damage(50)

	if body.is_in_group("movable_objects") and body.is_class("RigidBody3D"):
		var body_direction = direction
		var relative_direction = global_position - body.global_position
		var projected_direction = body_direction.project(relative_direction)
		body.apply_central_impulse(projected_direction.normalized() * move_speed)

	elif body.is_in_group("player"):
		var body_direction = direction
		var relative_direction = global_position - body.global_position
		var projected_direction = body_direction.project(relative_direction)
		body.velocity = projected_direction.normalized() * move_speed
		
		body.move_and_slide()



func _on_area_3d_body_exited(body:Node3D):
	if body.is_in_group("player"):
		body.IsInWater = false
