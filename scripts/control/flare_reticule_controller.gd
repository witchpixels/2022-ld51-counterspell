extends Node2D

export var flare_reticule_movement_speed: float = 100.0
export var flare_radius: float = 12.0;

var game_stage: GameStage
var game_settings: GameSettings
var active: bool = false

func _ready():
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")

func _process(delta):
	if (game_settings.use_controller):
		var movement_vector := Vector2(
			Input.get_axis("player_aim_left", "player_aim_right"),
			Input.get_axis("player_aim_up", "player_aim_down")).normalized()
			
		translate(movement_vector * flare_reticule_movement_speed * delta)

	else:
		position += Input.get_last_mouse_speed();

func _draw():
	draw_arc(get_global_transform().origin, flare_radius, 0.0, PI * 2.0, 128, Color.red, 2.0);


func stage_ready():
	set_process(true)
	game_stage = (owner as GameStage)
	game_settings = game_stage.get_game_settings()
	var _d = game_stage.get_timer().connect("timeout", self, "invoke_spell")
	_d = game_stage.get_player_state().connect("spell_has_changed", self, "spell_changed")
	spell_changed(game_stage.get_player_state().current_spell)

func invoke_spell():
	if active:
		print("flare boom");

func spell_changed(spell_name: String):
	active = spell_name == "flare"
	position = game_stage.get_player_state().world_position;
		