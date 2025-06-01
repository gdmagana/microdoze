extends Control

func _on_start_button_pressed():
	# Check if narrative intro should be skipped for debugging
	# (DebugSettings will only exist if added to AutoLoad)
	if has_node("/root/DebugSettings") and get_node("/root/DebugSettings").skip_narrative_intro:
		print("DEBUG: Skipping narrative intro, going directly to game")
		get_tree().change_scene_to_file("res://scenes/ice_cream_boss.tscn")
	else:
		# Normal flow: start with narrative intro
		get_tree().change_scene_to_file("res://scenes/narrative_one.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
