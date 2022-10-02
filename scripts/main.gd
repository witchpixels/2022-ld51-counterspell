extends Node2D

export var game_stage_scene: PackedScene;

onready var game_over: Control = $"./GameOver"
onready var boot_splash: Control = $"./BootFlow"

var current_game;

func _load_new_game():
	if current_game != null:
		remove_child(current_game)
	
	current_game = game_stage_scene.instance() as GameStage
	current_game.connect("ready", self, "_new_game_ready")
	add_child(current_game)

func _new_game_ready():
	current_game.get_player_state().connect("player_killed", self, "_on_BootFlow_finished")



func _on_BootFlow_finished():
	_load_new_game()
