extends CanvasLayer



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if get_parent().get_parent().started:
		$Label.text = "Current Disasters/Weather is: \n" + get_parent().get_parent().current_weather_and_disaster + "\nTime Left for the next disasters: \n" + str(int(get_parent().get_parent().get_node("Timer").time_left))
	else:
		$Label.text = "Waiting for players... Time remain: \n" + str(int(get_parent().get_parent().get_node("Timer").time_left))
