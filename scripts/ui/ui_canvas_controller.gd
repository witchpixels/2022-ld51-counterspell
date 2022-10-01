extends Control

onready var camera: Camera2D = get_parent()

func _process(_delta):
	set_size(get_node("/root").get_viewport().size * camera.zoom)

	