extends KinematicBody2D

signal game_stage_ready(game_stage)

export var movement_speed: float = 30
onready var timer 
onready var sprite: Sprite = $"./Sprite"
onready var hurt_sound: AudioStreamPlayer2D = $"./HurtSound"
onready var death_sound: AudioStreamPlayer2D = $"./DeathSound"

var game_stage: GameStage
var game_settings: GameSettings
var player_state: PlayerState

var current_spell_index = 0
var spells: Array = [
	"spike",
	"gale",
	"flare"
]

func _ready():
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")
	_i = death_sound.connect("finished", self, "_on_death_sound_played")

func _physics_process(delta):
	var movement_vector: Vector2 = (Vector2(
		Input.get_axis("player_left", "player_right"),
		Input.get_axis("player_up", "player_down"))).normalized()

	if (movement_vector.x < 0):
		sprite.flip_h = true
	elif (movement_vector.x > 0):
		sprite.flip_h = false

	var velocity = move_and_slide(movement_vector * movement_speed * delta)
	translate(velocity)
	player_state.world_position = position

func _process(_delta):
	if player_state.in_iframes:
		sprite.modulate.a = abs(sin(game_stage.timer.time_left * 50))
	else:
		sprite.modulate.a = 1.0
	
func stage_ready():
	set_process(true)
	game_stage = owner
	game_settings = game_stage.get_game_settings()
	player_state = game_stage.get_player_state()
	player_state.world_position = position
	player_state.player_body = self

	var _i = player_state.connect("player_hurt", self, "_on_hurt")
	_i = player_state.connect("player_killed", self, "_on_killed")
	_i = game_stage.get_timer().connect("timeout", self, "_on_timer_timeout")

	emit_signal("game_stage_ready", game_stage)

func do_damage(damage_amount: int, _damage_source: String):
	player_state.damage_player(damage_amount)

func _on_hurt():
	hurt_sound.play()

func _on_killed():
	death_sound.play()
	get_tree().paused = true

func _on_timer_timeout():
	current_spell_index = (current_spell_index + 1) % spells.size()
	player_state.call_deferred("set_spell", spells[current_spell_index])

func _on_death_sound_played():
	game_stage.reset_game_world()