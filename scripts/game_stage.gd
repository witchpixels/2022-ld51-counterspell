class_name GameStage extends Node2D

export var game_settings: Resource;
var player_state: PlayerState;

onready var timer = $"./Timer";

signal game_start()
signal exit_reached()

func _ready():
	player_state = PlayerState.new();

func get_game_settings() -> GameSettings:
	return game_settings as GameSettings;

func get_player_state() -> PlayerState:
	return player_state;

func get_timer() -> Timer:
	return timer;

func player_obtained_book():
	emit_signal("game_start")
	timer.start()

func player_entered_exit():
	emit_signal("exit_reached")