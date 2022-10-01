extends Node2D

export var book_speed: float = 5.0;
export var book_offset: Vector2 = Vector2.DOWN;
export var book_oscilation_rate: float = 2.0;
export var book_oscilation_distance: float = 3.0;

onready var player: KinematicBody2D = $"../Player"
onready var book_sprite = $"./BookSprite"

var total_timer: float = 0.0;

func _process(delta):
	var direction: Vector2 = (player.get_global_transform().origin + book_offset) - get_global_transform().origin;

	if (direction.length() > 1.0):
		translate(direction.normalized() * book_speed * delta)

	# making the book have a little animation
	total_timer += delta
	var book_local_transform: Vector2 = book_sprite.transform.origin;
	book_local_transform.y = round(sin(total_timer * book_oscilation_rate));

	book_sprite.transform.origin = book_local_transform;
