extends Camera2D

export var camera_speed: float = 1.0
export var wander_radius: float = 100

onready var player: KinematicBody2D = $"%Player"

func _physics_process(delta):
	var ideal_positon = player.get_global_transform().origin - get_viewport_rect().size / 2

	if (ideal_positon - position).length() > wander_radius:
		position = lerp(position, ideal_positon, delta * camera_speed)