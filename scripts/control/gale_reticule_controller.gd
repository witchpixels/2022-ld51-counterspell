extends Area2D

export var gale_shove_distance: float = 132;
export var gale_shove_speed: float = 100;
export var stun_duration: float = 2;


var game_stage: GameStage
var game_settings: GameSettings
var active: bool = false

func _ready():
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")


func stage_ready():
	set_process(true)
	game_stage = (owner as GameStage)
	game_settings = game_stage.get_game_settings()
	var _d = game_stage.get_timer().connect("timeout", self, "invoke_spell")
	_d = game_stage.get_player_state().connect("spell_has_changed", self, "spell_changed")
	spell_changed(game_stage.get_player_state().current_spell)

func invoke_spell():
	var targets = get_overlapping_bodies();

	var player_positon = game_stage.get_player_state().world_position;

	for target in targets:
		if target.has_method("shove"):
			target.shove(player_positon, gale_shove_distance, gale_shove_speed, stun_duration)

func spell_changed(spell_name: String):
	active = (spell_name == "gale")