extends Control

@onready var label = $RichTextLabel
@onready var timer = $Timer

var full_text = "This is a demo of words appearing one at a time in Godot."
var words = []
var word_index = 0

func _ready():
	words = full_text.split(" ")
	label.clear()
	timer.start(0.4)  # Adjust delay between words

func _on_Timer_timeout():
	if word_index < words.size():
		label.append_text(words[word_index] + " ")
		word_index += 1
	else:
		timer.stop()
