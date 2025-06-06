extends Control

func _on_restart_level_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(GameState.current_level_path)

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/startmenu.tscn")
