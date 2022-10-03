extends Area2D

export var highlight_color: Color;
export var unhighlighted_color: Color;
export var spike_damage: float = 1

onready var sprite: AnimatedSprite = $"./Sprite";
onready var particles: Particles2D = $"./Particles"
onready var sfx: AudioStreamPlayer2D = $"./Sfx"

var game_stage: GameStage
var game_settings: GameSettings
var active: bool = false

func _ready():
	set_process(false)
	var _i = owner.connect("game_stage_ready", self, "stage_ready")
	sprite.visible = false
	sprite.playing = false
	sprite.frame = 0

func _process(_delta):
	
	if !active:
		return

	var angle = 0.0

	if (game_settings.use_controller):
		var movement_vector := Vector2(
			Input.get_axis("player_aim_left", "player_aim_right"),
			Input.get_axis("player_aim_up", "player_aim_down")).normalized()

		if (movement_vector.length_squared() != 1):
			return;
		angle = rad2deg(movement_vector.angle())
	else:
		angle = rad2deg(global_position.direction_to(get_global_mouse_position()).angle())

	angle = int(angle / 45.0) * 45.0

	rotation_degrees = angle; 

func stage_ready(stage: GameStage):
	set_process(true)
	game_stage = stage
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

	var targets = get_overlapping_bodies();
	
	sfx.play()
	particles.restart()

	for target in targets:
		if target.has_method("do_damage"):
			target.do_damage(spike_damage, "spike")

func spell_changed(spell_name: String):
	active = spell_name == "spike"

	if active:
		sprite.modulate = highlight_color
		sprite.visible = true
	else:
		sprite.visible = false
		sprite.modulate = unhighlighted_color
		