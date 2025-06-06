extends Node

# Global audio manager for narrative scenes
# Handles blow.wav looping and bus switching

var audio_player: AudioStreamPlayer
var blow_audio_stream: AudioStreamWAV
var is_playing: bool = false

func _ready():
	# Set up as autoload (persistent across scenes)
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	# Load the blow.wav audio stream
	blow_audio_stream = load("res://assets/audio/blow.wav")
	
	# Create audio player
	audio_player = AudioStreamPlayer.new()
	audio_player.stream = blow_audio_stream
	audio_player.autoplay = false
	audio_player.bus = "Light"  # Start with Light bus (low pass filter)
	add_child(audio_player)

func start_narrative_audio():
	"""Start blow.wav audio on Light bus for narrative scenes"""
	if not is_playing:
		audio_player.bus = "Light"
		audio_player.play()
		is_playing = true
		print("Started narrative audio on Light bus")

func switch_to_heavy_bus():
	"""Switch to Heavy bus (for narrative scene 13)"""
	if is_playing:
		audio_player.bus = "Heavy"
		print("Switched narrative audio to Heavy bus")

func stop_narrative_audio():
	"""Stop and reset audio before Level 0"""
	if is_playing:
		audio_player.stop()
		is_playing = false
		print("Stopped narrative audio")

func get_audio_player():
	"""Get reference to the audio player for external access"""
	return audio_player

func _exit_tree():
	# Ensure audio stops when manager is destroyed
	stop_narrative_audio()
