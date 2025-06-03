extends Control

@export var full_mushrooms: Array[Texture2D]
@export var empty_mushrooms: Array[Texture2D]

func update_health(current_health: int):
	for i in range(3):
		var icon = $HBoxContainer.get_child(i)  # right to left
		if i < current_health:
			icon.texture = full_mushrooms[i]
		else:
			icon.texture = empty_mushrooms[i]
