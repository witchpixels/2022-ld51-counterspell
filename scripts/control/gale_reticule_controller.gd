extends Node2D

export var gale_radius: float = 128.0;

var game_stage: GameStage
var game_settings: GameSettings
var active: bool = false

func _ready():
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")

func _draw():
	draw_arc(get_global_transform().origin, gale_radius, 0.0, PI * 2.0, 128, Color.green, 2.0)


func stage_ready():
	set_process(true)
	game_stage = (owner as GameStage)
	game_settings = game_stage.get_game_settings()
	var _d = game_stage.get_timer().connect("timeout", self, "invoke_spell")
	_d = game_stage.get_player_state().connect("spell_has_changed", self, "spell_changed")
	spell_changed(game_stage.get_player_state().current_spell)

func invoke_spell():
	if active:
		print("gale push");

func spell_changed(spell_name: String):
	active = (spell_name == "gale")
		