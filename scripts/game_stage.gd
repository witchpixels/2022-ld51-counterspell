class_name GameStage extends Node2D

export var game_settings: Resource;
var player_state: PlayerState;

onready var timer = $"./Timer";

func _ready():
	player_state = PlayerState.new();

func get_game_settings() -> GameSettings:
	return game_settings as GameSettings;

func get_player_state() -> PlayerState:
	return player_state;

func get_timer() -> Timer:
	return timer;