extends Control

signal finished()

onready var video_player = $"%VideoPlayer"

func _ready():
	video_player.connect("finished", self, "_on_video_finished")
	video_player.play()

func _on_video_finished():
	emit_signal("finished")
	get_parent().remove_child(self)