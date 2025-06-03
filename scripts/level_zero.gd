extends Node2D

@onready var player = $Player
@onready var bounce_hint_label = $Player/OnBounceLabel

var gave_bounce_hint = false

@export var projectile_icicle: PackedScene
var icicle_spawned = false

func _ready():
	add_to_group("level_zero")
	player.can_lose_health = false
	bounce_hint_label.visible = false
	player.connect("bounced_off_ice", Callable(self, "_on_player_bounce_off_ice"))
	
func _on_player_bounce_off_ice():
	if not gave_bounce_hint:
		bounce_hint_label.visible = true
		gave_bounce_hint = true
			
func _input(event):	
	if bounce_hint_label.visible and Input.is_action_just_pressed("shoot_puck"):
		bounce_hint_label.visible = false
	
func _process(delta):
	if not icicle_spawned and player.position.y < 710:
		#spawn_icicle()
		icicle_spawned = true
		
func spawn_icicle():
	var icicle = projectile_icicle.instantiate()
	icicle.position = Vector2(player.position.x, 0)	
	var direction = (player.position - icicle.position).normalized()
	icicle.velocity = direction * 400
	add_child(icicle)
	
