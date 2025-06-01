extends Control

@onready var label = $Label
@onready var timer = $Timer

var full_text = ""
var char_index = 0

func _ready():
	label.text = ""
	char_index = 0

	# Get scene name safely
	var scene_name = get_tree().current_scene.name

	# Set full_text based on scene
	match scene_name:
		"NarrativeTwo":
			full_text = "I wish I had something fun to do tonight"
		"NarrativeThree":
			full_text = "You wanna have fun tonight? I got you bro"
		"NarrativeFour":
			full_text = "Try a small bite of this"
		"NarrativeFive":
			full_text = "Hmm..."
		"NarrativeSix":
			full_text = "*Nom Nom*"
		"NarrativeSeven":
			full_text = "Hmm..."
		"NarrativeEight":
			full_text = "*Nom Nom*"
		"NarrativeNine":
			full_text = "Fuck..."
		"NarrativeTen":
			full_text = "Uhh imma go..."
		"NarrativeTwelve":
			full_text = "I'm really hungry..."
		"NarrativeFourteen":
			full_text = "THE FREEZER BECKONS"
		_:
			full_text = "..."  # fallback or empty

	# Start the text reveal
	timer.start(0.05)

func _on_Timer_timeout():
	if char_index < full_text.length():
		label.text += full_text[char_index]
		char_index += 1
	else:
		timer.stop()
