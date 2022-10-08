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
	current_game.connect("exit_reached", self, "_on_exit_reached")
	add_child(current_game)

func _new_game_ready():
	current_game.connect("reset_needed", self, "_on_player_killed")

func _on_player_killed():
	remove_child(current_game)
	var timer = get_tree().create_timer(5)
	timer.connect("timeout", self, "_on_BootFlow_finished");

func _on_BootFlow_finished():
	_load_new_game()

func _on_exit_reached():
	remove_child(current_game)
	remove_child(game_over)