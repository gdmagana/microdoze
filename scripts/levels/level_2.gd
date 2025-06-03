extends Node2D

func _process(_delta):
	var material: ShaderMaterial = $Snow.material
	material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
	
