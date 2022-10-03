extends Node2D

export var child_animation_delay_seconds: float = 0.1
export var animation_duration: float = 0.0


func _ready():
	visible = false
	var _i = get_child(get_child_count() - 1).connect("animation_finished", self, "_on_last_child_animation_done")

func _process(delta):
	if (!visible):
		return
	
	for i in get_child_count():
		var child = get_child(i)
		if child is AnimatedSprite:
			if !child.playing:
				if animation_duration > child_animation_delay_seconds:
					child.frame = 0
					child.playing = true
					animation_duration = 0
	animation_duration += delta
	
func _on_last_child_animation_done():
	visible = false
	animation_duration = 0.0
	for i in get_child_count():
		var child = get_child(i)
		if child is AnimatedSprite:
			child.frame = 0
			child.playing = false


