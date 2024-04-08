extends Node3D

var magnitude = 8
var magnitude_modifier = 0

func _physics_process(_delta):
	magnitude_modifier_increment()
	shake_nodes(get_parent())


func magnitude_modifier_increment():
	# Ajustar el valor de MagnitudeModifier
	self.magnitude_modifier = clamp(self.magnitude_modifier + (get_physics_process_delta_time() / 4), 0, 1)


func shake_nodes(node):
	# Variables locales
	var scale_velocity: float = 66 / (1 / get_physics_process_delta_time()) # Calcula la escala de la velocidad
	var mag: float = self.magnitude * self.magnitude_modifier

	# Calcula el factor de modificación de la física según la magnitud
	var mag_physmod: float = (mag - 3) / 7

	# Calcula el vector de velocidad
	var vec: Vector3 = Vector3(randi_range(-15, 15) / 10, randi_range(-5, 4) / 10, randi_range(-15, 15) / 10 ) * (mag * 25)

	# Calcula el vector de velocidad angular
	var ang_vv: Vector3 = Vector3(randi_range(-15, 15) / 10, randi_range(-5, 4) / 10, randi_range(-15, 15) / 10 ) * (mag * 8)

	# Si hay una probabilidad de golpear, aumenta el vector de velocidad angular
	if Globals.hit_chance(2):
		ang_vv *= 20


	for child in node.get_children():
		if child.is_in_group("player"): # Verifica si el nodo es un Spatial (objeto 3D)
			if child.is_on_floor():
				child.velocity = vec * 1.125
				child.move_and_slide()
		elif child.is_in_group("movable_objects") and child.is_class("RigidBody3D"):
			var mass = child.mass
			var velocity_magnitude = child.linear_velocity.length()
			var vel_mod = 1 - clamp(velocity_magnitude / 2000, 0, 1)
			var ang_v = ang_vv * vel_mod
			if mass < 13600:
				child.add_constant_torque(ang_v * 8)
				child.add_constant_central_force(ang_v * 4)
				child.freeze = false

		# Llama recursivamente a la función para procesar los hijos del nodo actual
		if child.get_child_count() > 0:
			shake_nodes(child)