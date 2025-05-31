extends Control

# Debug UI for showing active powerups
@onready var speed_label: Label
@onready var unlimited_label: Label
@onready var fire_label: Label
@onready var invincibility_label: Label
@onready var debug_container: VBoxContainer

func _ready():
	# Create the debug UI
	create_debug_ui()
	
	# Connect to PowerUpManager signals if available
	if PowerUpManager:
		PowerUpManager.speed_boost_started.connect(_on_speed_boost_started)
		PowerUpManager.speed_boost_ended.connect(_on_speed_boost_ended)
		PowerUpManager.unlimited_pucks_started.connect(_on_unlimited_pucks_started)
		PowerUpManager.unlimited_pucks_ended.connect(_on_unlimited_pucks_ended)
		PowerUpManager.fire_pucks_started.connect(_on_fire_pucks_started)
		PowerUpManager.fire_pucks_ended.connect(_on_fire_pucks_ended)
		PowerUpManager.invincibility_started.connect(_on_invincibility_started)
		PowerUpManager.invincibility_ended.connect(_on_invincibility_ended)

func create_debug_ui():
	# Create a container for debug info
	debug_container = VBoxContainer.new()
	debug_container.position = Vector2(10, 10)
	add_child(debug_container)
	
	# Title label
	var title_label = Label.new()
	title_label.text = "POWERUP DEBUG"
	title_label.add_theme_color_override("font_color", Color.WHITE)
	debug_container.add_child(title_label)
	
	# Speed boost label
	speed_label = Label.new()
	speed_label.text = "Speed Boost: OFF"
	speed_label.add_theme_color_override("font_color", Color.CYAN)
	debug_container.add_child(speed_label)
	
	# Unlimited pucks label
	unlimited_label = Label.new()
	unlimited_label.text = "Unlimited Pucks: OFF"
	unlimited_label.add_theme_color_override("font_color", Color.YELLOW)
	debug_container.add_child(unlimited_label)
	
	# Fire pucks label
	fire_label = Label.new()
	fire_label.text = "Fire Pucks: OFF"
	fire_label.add_theme_color_override("font_color", Color.ORANGE)
	debug_container.add_child(fire_label)
	
	# Invincibility label
	invincibility_label = Label.new()
	invincibility_label.text = "Invincibility: OFF"
	invincibility_label.add_theme_color_override("font_color", Color.WHITE)
	debug_container.add_child(invincibility_label)

func _process(_delta):
	# Update debug info every frame
	if PowerUpManager:
		# Speed boost
		if PowerUpManager.speed_boost_active:
			speed_label.text = "Speed Boost: ON (%.1fs)" % PowerUpManager.speed_boost_timer
		else:
			speed_label.text = "Speed Boost: OFF"
		
		# Unlimited pucks
		if PowerUpManager.unlimited_pucks_active:
			unlimited_label.text = "Unlimited Pucks: ON (%.1fs)" % PowerUpManager.unlimited_pucks_timer
		else:
			unlimited_label.text = "Unlimited Pucks: OFF"
		
		# Fire pucks
		if PowerUpManager.fire_pucks_active:
			fire_label.text = "Fire Pucks: ON (%d left)" % PowerUpManager.fire_pucks_remaining
		else:
			fire_label.text = "Fire Pucks: OFF"
		
		# Invincibility
		if PowerUpManager.invincibility_active:
			invincibility_label.text = "Invincibility: ON (%.1fs)" % PowerUpManager.invincibility_timer
			# Make the label flash between white and rainbow colors for effect
			var time = Time.get_time_dict_from_system()
			var flash_value = sin(time.second * 10.0 + time.minute) * 0.5 + 0.5
			invincibility_label.modulate = Color(1.0, flash_value, 1.0 - flash_value)
		else:
			invincibility_label.text = "Invincibility: OFF"
			invincibility_label.modulate = Color.WHITE
	else:
		speed_label.text = "Speed Boost: PowerUpManager NOT FOUND!"
		unlimited_label.text = "Unlimited Pucks: PowerUpManager NOT FOUND!"
		fire_label.text = "Fire Pucks: PowerUpManager NOT FOUND!"
		invincibility_label.text = "Invincibility: PowerUpManager NOT FOUND!"

# Signal handlers
func _on_speed_boost_started():
	print("DEBUG: Speed boost started!")

func _on_speed_boost_ended():
	print("DEBUG: Speed boost ended!")

func _on_unlimited_pucks_started():
	print("DEBUG: Unlimited pucks started!")

func _on_unlimited_pucks_ended():
	print("DEBUG: Unlimited pucks ended!")

func _on_fire_pucks_started():
	print("DEBUG: Fire pucks started!")

func _on_fire_pucks_ended():
	print("DEBUG: Fire pucks ended!")

func _on_invincibility_started():
	print("DEBUG: Invincibility started!")

func _on_invincibility_ended():
	print("DEBUG: Invincibility ended!")