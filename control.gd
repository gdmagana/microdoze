extends Control

func _ready():
	if GameState.show_continue_button:
		$BeginGame.visible = false
		$VBoxContainer.visible = true
	set_process_input(true)

func _process(_delta):
	var material: ShaderMaterial = $Background.material
	material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
	
func _input(event):
	if event.is_action_pressed("start_game"):
		GameState.show_continue_button = true
		get_tree().change_scene_to_file("res://scenes/narrative/intro/narrative_1.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/narrative/intro/narrative_1.tscn")

func _on_continue_old_game_pressed() -> void:
	get_tree().change_scene_to_file(GameState.current_level_path)
