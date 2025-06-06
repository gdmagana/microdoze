extends Control

# Reference to the remaining pucks label
@onready var remaining_pucks_label = $HBoxContainer/RemainingPucks

# Function to update the displayed puck count
func update_puck_count(max_pucks: int, active_pucks: int):
	var remaining = max_pucks - active_pucks
	if remaining_pucks_label:
		remaining_pucks_label.text = "x " + str(remaining)
