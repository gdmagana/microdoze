extends Node2D

@onready var ice_cream_boss = $IceCreamBoss
@onready var arrow = $ArrowIndicator

func _ready():
	add_to_group("level_one")
	
	ice_cream_boss.connect("ran_away", Callable(self, "_on_boss_ran_away"))
	
func _on_boss_ran_away():
	await get_tree().create_timer(3).timeout
	arrow.visible = true
	arrow.start_flashing()
