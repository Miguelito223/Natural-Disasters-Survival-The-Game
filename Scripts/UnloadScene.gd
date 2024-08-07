extends Node

signal progress_changed(progress)
signal unload_done

var unloading_screen_path: String = "res://Scenes/loading_screen.tscn"
var unloading_screen = load(unloading_screen_path)
var unloader_resource: PackedScene
var scene
var scene_path: String
var progress: Array = []

var use_sub_theads: bool = false

func unload_scene(current_scene):

	if current_scene != null and is_instance_valid(current_scene):
		scene_path = current_scene.scene_file_path
		scene = current_scene
		
	var unloading_screen_scene = unloading_screen.instantiate()
	Globals.main.add_child(unloading_screen_scene)
	
	self.progress_changed.connect(unloading_screen_scene.update_progress_bar)
	self.unload_done.connect(unloading_screen_scene.fade_out_loading_screen)

	await Signal(unloading_screen_scene, "safe_to_load")

	if current_scene != null and is_instance_valid(current_scene):
		current_scene.queue_free()

	var loader_next_scene = ResourceLoader.load_threaded_request(scene_path, "", use_sub_theads)
	if loader_next_scene == OK:
		print("is ok")
		set_process(true)

func _process(_delta):
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	match load_status:
		0:
			print("failed to load: invalid resource")
			set_process(false)
			return
		2:
			print("failed to load")
			set_process(false)
			return
		1:
			print("progressin")
			emit_signal("progress_changed", progress[0])
		3:
			print("Completed")
			emit_signal("progress_changed", 1.0)
			emit_signal("unload_done")
			set_process(false)

