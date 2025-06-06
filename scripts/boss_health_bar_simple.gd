extends Control
class_name BossHealthBarSimple

@onready var health_bar_frame: TextureRect = $HealthBarFrame
@onready var health_bar_fill: ColorRect = $HealthBarFill

var max_health: float = 100.0
var current_health: float = 100.0

func _ready():
	# Initialize health bar
	update_health(current_health, max_health)

func update_health(health: float, max_health_value: float):
	current_health = health
	max_health = max_health_value
	
	if not health_bar_fill:
		print("DEBUG: Health fill not found!")
		return
	
	# Calculate health percentage
	var health_percentage = clamp(health / max_health_value, 0.0, 1.0)
	
	# Update fill width
	health_bar_fill.anchor_right = health_percentage

func flash_damage():
	if not health_bar_fill:
		return
		
	# Flash white briefly
	var original_color = health_bar_fill.color
	health_bar_fill.color = Color.WHITE
	
	# Return to original color after brief flash
	await get_tree().create_timer(0.1).timeout
	health_bar_fill.color = original_color

func show_health_bar():
	visible = true

func hide_health_bar():
	visible = false
