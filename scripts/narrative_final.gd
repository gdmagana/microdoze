extends Node2D
func _process(delta):
	if Input.is_action_just_pressed("back_to_menu"):
		get_tree().change_scene_to_file("res://scenes/startmenu.tscn")
