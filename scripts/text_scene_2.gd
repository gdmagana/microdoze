extends Control

@onready var label = $Label
@onready var timer = $Timer

var full_text = ""
var char_index = 0
var current_speaker = "main_character" # Default speaker

# Character voice configurations
var character_voices = {
	"main_character": {
		"base_pitch": 1.0,
		"pitch_variance": 0.2,
		"volume": -5.0,
		"play_chance": 0.8  # 80% chance to play sound on each character
	},
	"frat_bro": {
		"base_pitch": 0.8,
		"pitch_variance": 0.15,
		"volume": -3.0,
		"play_chance": 0.9
	}
}

func _ready():
	label.text = ""
	char_index = 0

	# Get scene name safely
	var scene_name = get_tree().current_scene.name

	# Set full_text and speaker based on scene
	match scene_name:
		"NarrativeTwo":
			full_text = "I wish I had something fun to do tonight"
			current_speaker = "main_character"
		"NarrativeThree":
			full_text = "You wanna have fun tonight? I got you bro"
			current_speaker = "frat_bro"
		"NarrativeFour":
			full_text = "Try a small bite of this"
			current_speaker = "frat_bro"
		"NarrativeFive":
			full_text = "Hmm..."
			current_speaker = "main_character"
		"NarrativeSix":
			full_text = "*Nom Nom*"
			current_speaker = "main_character"
		"NarrativeSeven":
			full_text = "Hmm..."
			current_speaker = "main_character"
		"NarrativeEight":
			full_text = "*Nom Nom*"
			current_speaker = "main_character"
		"NarrativeNine":
			full_text = "Fuck..."
			current_speaker = "main_character"
		"NarrativeTen":
			full_text = "Uhh imma go..."
			current_speaker = "frat_bro"
		"NarrativeTwelve":
			full_text = "I'm really hungry..."
			current_speaker = "main_character"
		"NarrativeFourteen":
			full_text = "THE FREEZER BECKONS"
			current_speaker = "main_character"
		_:
			full_text = "..."  # fallback or empty
			current_speaker = "main_character"

	# Start the text reveal
	timer.start(0.05)

func _on_Timer_timeout():
	if char_index < full_text.length():
		var current_char = full_text[char_index]
		label.text += current_char
		
		# Play dialog sound for non-space characters
		if current_char != " " and current_char != "\n":
			play_dialog_sound()
		
		char_index += 1
	else:
		timer.stop()

func play_dialog_sound():
	# Get the current speaker's voice settings
	var voice_config = character_voices.get(current_speaker, character_voices["main_character"])
	
	# Random chance to play sound (makes it feel more natural)
	if randf() > voice_config.play_chance:
		return
	
	# Try to find an AudioStreamPlayer on the current speaker
	var audio_player = find_character_audio_player()
	if audio_player == null:
		return
	
	# If it's our custom dialog audio generator, use the blip method
	if audio_player.has_method("play_dialog_blip"):
		audio_player.play_dialog_blip()
	else:
		# Fallback for regular AudioStreamPlayer with audio files
		var pitch_variation = randf_range(-voice_config.pitch_variance, voice_config.pitch_variance)
		audio_player.pitch_scale = voice_config.base_pitch + pitch_variation
		audio_player.volume_db = voice_config.volume
		audio_player.play()

func find_character_audio_player():
	# Look for character nodes in the parent scene
	var scene_root = get_tree().current_scene
	
	# Try to find the character node and its AudioStreamPlayer
	match current_speaker:
		"main_character":
			var main_char = scene_root.get_node_or_null("MainCharacter")
			if main_char:
				var dialog_audio = main_char.get_node_or_null("DialogAudio")
				return dialog_audio
			else:
				main_char = scene_root.get_node_or_null("MainCharacterEat")
				if main_char:
					var dialog_audio = main_char.get_node_or_null("DialogAudio")
					return dialog_audio
		"frat_bro":
			var frat_bro = scene_root.get_node_or_null("FratBro")
			if frat_bro:
				var dialog_audio = frat_bro.get_node_or_null("DialogAudio")
				return dialog_audio
			else:
				frat_bro = scene_root.get_node_or_null("FratBroShocked")
				if frat_bro:
					var dialog_audio = frat_bro.get_node_or_null("DialogAudio")
					return dialog_audio
	
	# Fallback: look for a general dialog audio player
	var fallback_audio = scene_root.get_node_or_null("DialogAudio")
	return fallback_audio
