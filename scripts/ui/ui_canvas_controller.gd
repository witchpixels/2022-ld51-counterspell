extends Control

onready var camera: Camera2D = $"%Camera2D"

func _process(_delta):
	set_position(-get_node("/root").get_viewport().size * 0.5)
	set_size(get_node("/root").get_viewport().size)

	