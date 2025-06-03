extends Control

func _ready():
	# Connect button signals
	$RestartButton.connect("pressed", Callable(self, "_on_restart_pressed"))
	$QuitButton.connect("pressed", Callable(self, "_on_quit_pressed"))
	
	# Make sure this is on top of everything else
	show()
	
func _on_restart_pressed():
	# Restart the game from the start menu
	get_tree().change_scene_to_file("res://scenes/startmenu.tscn")
	
func _on_quit_pressed():
	# Quit the game
	get_tree().quit()
