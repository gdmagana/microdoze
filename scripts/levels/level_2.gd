extends Node2D

@onready var ice_cream_boss = $IceCreamBoss
@onready var arrow = $ArrowIndicator

func _process(_delta):
	var material: ShaderMaterial = $Snow.material
	material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)

func _ready():
	add_to_group("level_two")
	
	if ice_cream_boss:
		ice_cream_boss.connect("ran_away", Callable(self, "_on_boss_ran_away"))
	
func _on_boss_ran_away():
	await get_tree().create_timer(3).timeout
	if arrow:
		arrow.visible = true
		arrow.start_flashing()
