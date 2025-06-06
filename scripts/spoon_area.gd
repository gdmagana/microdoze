extends Area2D
	
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
		SpoonSprite.visible = true
		var Stick = body.get_node("Stick")
		Stick.visible = false
		var aura = get_parent().get_node("DyingBoss").get_node("Aura")
		aura.visible = true
		queue_free()  # deletes the spoon
		print("You got the spoon!")
