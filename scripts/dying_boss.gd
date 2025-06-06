extends Area2D

@onready var player = get_parent().get_node("Player")

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	flash_aura()

func flash_aura():
	var aura = $Aura
	var tween = create_tween()
	tween.set_loops()  # infinite
	tween.tween_property(aura, "modulate:a", 0.7, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(aura, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_body_entered(body):
	if body.is_in_group("player"):
		var SpoonSprite = body.get_node("SpoonSprite")
		if SpoonSprite.visible:
			if player:
				player.lock_player()
			var label = get_parent().get_node("Label")
			label.text = "omg  that \ntickles!"
			await get_tree().create_timer(2.0).timeout
			get_tree().change_scene_to_file("res://scenes/narrative_final.tscn")
		else:
			var label = get_parent().get_node("Label")
			label.text = "bro  have\nsome  manners\nuse  a \n spoon"
			

			

	
			
