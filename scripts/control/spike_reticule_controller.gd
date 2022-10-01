extends Node2D

export var spike_range: float = 256.0
export var spike_radius: float = 15.0;

var game_stage: GameStage
var game_settings: GameSettings
var active: bool = false

# wpx2022 TODO: Replace with better rendering
var angle: float;

func _ready():
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")

func _process(_delta):
	
	angle = 0.0

	if (game_settings.use_controller):
		var movement_vector := Vector2(
			Input.get_axis("player_aim_left", "player_aim_right"),
			Input.get_axis("player_aim_up", "player_aim_down")).normalized()
		angle = rad2deg(movement_vector.angle())
	else:
		angle = 46.25;

	angle = int(angle / 45.0) * 45.0

	rotation_degrees = angle; 
		

func _draw():

	var angle_start = deg2rad(angle - spike_radius)
	var angle_end = deg2rad(angle + spike_radius)

	draw_arc(position, spike_range, angle_start, angle_end, 128, Color.cyan, 2.0)


func stage_ready():
	set_process(true)
	game_stage = (owner as GameStage)
	game_settings = game_stage.get_game_settings()
	var _d = game_stage.get_timer().connect("timeout", self, "invoke_spell")
	_d = game_stage.get_player_state().connect("spell_has_changed", self, "spell_changed")
	spell_changed(game_stage.get_player_state().current_spell)

func invoke_spell():
	if active:
		print("spike stab");

func spell_changed(spell_name: String):
	active = spell_name == "spike"
		