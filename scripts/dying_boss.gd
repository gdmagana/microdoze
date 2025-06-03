extends Area2D

var hits := 0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player") and hits >= 2:
		get_tree().change_scene_to_file("res://scenes/narrative_final.tscn")
	if body.is_in_group("puck"):
		# Use call_deferred to avoid changing physics state during physics processing
		hits += 1
		if body.has_method("destroy_puck"):
			body.destroy_puck()
		
		if hits == 2:
			$Closed.visible = false
			$Open.visible = true
			var label = get_node("../Label")
			
			label.text = "Come eat shayla!"

			

	
			
