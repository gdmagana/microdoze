extends Area2D

@export var projectile_scene: PackedScene
@export var throw_speed: float = 400.0

var player: Node2D

func _ready():
	player = get_tree().get_current_scene().find_child("Player", true, false)
	$Timer.timeout.connect(_on_Timer_timeout)
	
func _on_Timer_timeout():
	if player:
		# instantiate the projectile at the boss' position
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position
		
		# "throw" the projectile at the player
		var direction = (player.global_position - global_position).normalized()
		projectile.velocity = direction * throw_speed
