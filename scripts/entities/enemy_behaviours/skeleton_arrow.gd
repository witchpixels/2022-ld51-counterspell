extends KinematicBody2D

export var arrow_damage: int = 1
export var speed: float = 100
export var life_span_seconds: float = 5

var direction: Vector2


func _enter_tree():
	direction = Vector2(cos(deg2rad(rotation_degrees)), sin(deg2rad(rotation_degrees)))

func _process(delta):
	life_span_seconds -= delta

	if life_span_seconds <= 0:
		get_parent().remove_child(self)
		return

	var collision = move_and_collide(direction * speed * delta)

	if collision != null:
		translate(collision.travel)
		if collision.collider.has_method("do_damage"):
			collision.collider.do_damage(arrow_damage, "arrow")
		get_parent().remove_child(self)
	else:
		translate(direction * speed * delta)

