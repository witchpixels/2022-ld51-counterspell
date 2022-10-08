class_name GameStage extends Node2D

export var game_settings: Resource
var player_state: PlayerState

onready var timer = $"./Timer"
onready var book_collect_sfx: AudioStreamPlayer2D = $"./BookCollectSfx"
onready var music: AudioStreamPlayer = $"./Music"

signal game_start()
signal exit_reached()
signal reset_needed()

func _ready():
	player_state = PlayerState.new()
	get_tree().paused = false

func get_game_settings() -> GameSettings:
	return game_settings as GameSettings

func get_player_state() -> PlayerState:
	return player_state

func get_timer() -> Timer:
	return timer

func player_obtained_book():
	book_collect_sfx.play()
	music.play()
	music.autoplay = true
	emit_signal("game_start")
	timer.start()

func player_entered_exit():
	emit_signal("exit_reached")

func reset_game_world():
	emit_signal("reset_needed")