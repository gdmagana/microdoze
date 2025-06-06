extends Sprite2D

func _process(delta):
	position.y += sin(Time.get_ticks_msec() / 300.0) * 0.2
