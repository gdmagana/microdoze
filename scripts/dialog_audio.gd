extends AudioStreamPlayer

# Dialog sound system using actual audio samples
# Uses audio files from assets/audio/voice/

@export var character_type: String = "default"  # "main_character", "frat_bro", etc.

# Character voice samples - add your audio files here
var voice_samples = {
	"main_character": [
		"res://assets/audio/voice/telandSample.wav"
	],
	"frat_bro": [
		"res://assets/audio/voice/gabeSample.wav"
	]
}

# Character voice settings
var voice_settings = {
	"main_character": {
		"pitch_range": [0.9, 1.1],
		"volume_db": -8.0
	},
	"frat_bro": {
		"pitch_range": [0.7, 0.9],  # Lower pitch for frat bro
		"volume_db": -5.0
	}
}

func _ready():
	# Configure character-specific settings
	setup_character_voice()

func setup_character_voice():
	var settings = voice_settings.get(character_type, voice_settings["main_character"])
	volume_db = settings.volume_db
	
	# Load the first sample as default
	var samples = voice_samples.get(character_type, voice_samples["main_character"])
	if samples.size() > 0:
		var audio_sample = load(samples[0])
		if audio_sample:
			stream = audio_sample

func play_dialog_blip():
	# Get random sample if multiple available
	var samples = voice_samples.get(character_type, voice_samples["main_character"])
	if samples.size() == 0:
		return
		
	# Pick random sample for variety
	var sample_path = samples[randi() % samples.size()]
	var audio_sample = load(sample_path)
	if audio_sample:
		stream = audio_sample
	
	# Apply random pitch variation
	var settings = voice_settings.get(character_type, voice_settings["main_character"])
	var pitch_range = settings.pitch_range
	pitch_scale = randf_range(pitch_range[0], pitch_range[1])
	
	# Play the sound
	play()

# Simpler method that just plays with current settings
func play_simple_blip():
	if stream == null:
		setup_character_voice()
	
	# Apply slight pitch variation
	var settings = voice_settings.get(character_type, voice_settings["main_character"])
	var pitch_range = settings.pitch_range
	pitch_scale = randf_range(pitch_range[0], pitch_range[1])
	
	play()
