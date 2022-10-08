extends Node2D

export var book_speed: float = 5.0
export var book_offset: Vector2 = Vector2.DOWN
export var book_oscilation_rate: float = 2.0
export var book_oscilation_distance: float = 3.0

onready var player: KinematicBody2D = $"../Player"
onready var book_sprite = $"./BookSprite"

var total_timer: float = 0.0
var book_obtained: bool = false

func _ready():
	var _i = owner.connect("ready", self, "_on_stage_ready")

func _process(delta):
	if !book_obtained:
		return

	var direction: Vector2 = (player.position + book_offset) - position

	if (direction.length() > 1.0):
		translate(direction.normalized() * book_speed * delta)

	# making the book have a little animation
	total_timer += delta
	var book_local_transform: Vector2 = book_sprite.transform.origin
	book_local_transform.y = round(sin(total_timer * book_oscilation_rate))

	book_sprite.transform.origin = book_local_transform

func _on_stage_ready():
	var game_stage = owner as GameStage
	game_stage.connect("game_start", self, "_on_book_obtained")

func _on_book_obtained():
	book_obtained = true