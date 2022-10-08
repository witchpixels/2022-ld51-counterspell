extends Label

onready var timer: Timer = $"%Timer"

func _process(_delta):
	var time_left = timer.time_left
	text = "%00.2f" %  time_left