extends Label

var timer: Timer;

func _ready():
	timer = get_node("/root/GameStage/Timer")

func _process(_delta):
	var time_left = timer.time_left;
	text = "%00.2f" %  time_left;