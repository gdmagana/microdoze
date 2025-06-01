extends Node

# Singleton to manage all powerup effects
# Add this to AutoLoad in Project Settings

signal speed_boost_started
signal speed_boost_ended
signal unlimited_pucks_started
signal unlimited_pucks_ended
signal fire_pucks_started
signal fire_pucks_ended
signal invincibility_started
signal invincibility_ended

# Speed boost effect
var speed_boost_active := false
var speed_boost_timer := 0.0
var speed_boost_multiplier := 2.0

# Unlimited pucks effect
var unlimited_pucks_active := false
var unlimited_pucks_timer := 0.0

# Fire pucks effect
var fire_pucks_active := false
var fire_pucks_timer := 0.0

# Invincibility effect
var invincibility_active := false
var invincibility_timer := 0.0

var player: Node2D

func _ready():
	# Find player reference when scene starts
	call_deferred("find_player")

func find_player():
	player = get_tree().get_current_scene().find_child("Player", true, false)

func _process(delta):
	# Handle speed boost timer
	if speed_boost_active:
		speed_boost_timer -= delta
		if speed_boost_timer <= 0:
			end_speed_boost()
	
	# Handle unlimited pucks timer
	if unlimited_pucks_active:
		unlimited_pucks_timer -= delta
		if unlimited_pucks_timer <= 0:
			end_unlimited_pucks()
	
	# Handle fire pucks timer
	if fire_pucks_active:
		fire_pucks_timer -= delta
		if fire_pucks_timer <= 0:
			end_fire_pucks()
	
	# Handle invincibility timer
	if invincibility_active:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			end_invincibility()

# Speed Boost PowerUp
func activate_speed_boost(duration: float = 5.0):
	speed_boost_active = true
	speed_boost_timer = duration
	speed_boost_started.emit()

func end_speed_boost():
	speed_boost_active = false
	speed_boost_timer = 0.0
	speed_boost_ended.emit()

func get_speed_multiplier() -> float:
	return speed_boost_multiplier if speed_boost_active else 1.0

# Unlimited Pucks PowerUp
func activate_unlimited_pucks(duration: float = 3.0):
	unlimited_pucks_active = true
	unlimited_pucks_timer = duration
	unlimited_pucks_started.emit()

func end_unlimited_pucks():
	unlimited_pucks_active = false
	unlimited_pucks_timer = 0.0
	unlimited_pucks_ended.emit()

func has_unlimited_pucks() -> bool:
	return unlimited_pucks_active

# Fire Pucks PowerUp
func activate_fire_pucks(duration: float = 3.0):
	fire_pucks_active = true
	fire_pucks_timer = duration
	fire_pucks_started.emit()

func end_fire_pucks():
	fire_pucks_active = false
	fire_pucks_timer = 0.0
	fire_pucks_ended.emit()

func has_fire_pucks() -> bool:
	return fire_pucks_active and fire_pucks_timer > 0

func get_fire_pucks_remaining() -> float:
	return fire_pucks_timer

# Invincibility PowerUp
func activate_invincibility(duration: float = 5.0):
	invincibility_active = true
	invincibility_timer = duration
	invincibility_started.emit()

func end_invincibility():
	invincibility_active = false
	invincibility_timer = 0.0
	invincibility_ended.emit()

func is_invincible() -> bool:
	return invincibility_active

func get_invincibility_timer() -> float:
	return invincibility_timer
