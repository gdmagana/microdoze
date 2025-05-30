extends Control

func _on_start_button_pressed():
	# Start button should lead to the main game
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
