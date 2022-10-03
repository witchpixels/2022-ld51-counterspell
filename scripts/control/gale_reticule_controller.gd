extends Area2D

export var highlight_color: Color;
export var unhighlighted_color: Color;
export var gale_shove_distance: float = 132;
export var gale_shove_speed: float = 100;
export var stun_duration: float = 2;
export var gale_reticule_movement_speed: float = 100.0
export var gale_max_distance: float = 256.0;

onready var sprite: AnimatedSprite = $"./Sprite";
onready var particles: Particles2D = $"./Particles"
onready var sfx: AudioStreamPlayer2D = $"./Sfx"

var game_stage: GameStage
var game_settings: GameSettings
var active: bool = false

func _ready():
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")
	sprite.visible = false
	sprite.playing = false
	sprite.frame = 0

func _process(delta):

	clamp_position(delta)

	if !active:
		return

	if (game_settings.use_controller):
		var movement_vector := Vector2(
			Input.get_axis("player_aim_left", "player_aim_right"),
			Input.get_axis("player_aim_up", "player_aim_down")).normalized()
			
		translate(movement_vector * gale_reticule_movement_speed * delta)
	else:
		position = get_global_mouse_position();
		clamp_position(delta);

func stage_ready():
	set_process(true)
	game_stage = (owner as GameStage)
	game_settings = game_stage.get_game_settings()
	var _d = game_stage.get_timer().connect("timeout", self, "invoke_spell")
	_d = game_stage.get_player_state().connect("spell_has_changed", self, "spell_changed")
	spell_changed(game_stage.get_player_state().current_spell)

	var _i = game_stage.connect("game_start", self, "on_book_obtained") 

func on_book_obtained():
	sprite.playing = true

func invoke_spell():
	sprite.frame = 0

	if !active:
		return

	sfx.play()
	particles.restart()
	var targets = get_overlapping_bodies();

	for target in targets:
		if target.has_method("stun"):
			target.stun(stun_duration)

func spell_changed(spell_name: String):
	active = (spell_name == "gale")
	
	if active:
		position = game_stage.get_player_state().world_position
		sprite.modulate = highlight_color
		sprite.visible = true
	else:
		sprite.visible = false
		sprite.modulate = unhighlighted_color

func clamp_position(delta):
	var player_position = game_stage.get_player_state().world_position
	if (abs(position.distance_to(player_position)) > gale_max_distance):
		position = lerp(position, player_position.direction_to(position) * gale_max_distance + player_position, delta * gale_reticule_movement_speed)
		