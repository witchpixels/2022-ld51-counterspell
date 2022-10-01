extends KinematicBody2D

export var movement_speed: float = 30;

onready var sprite: Sprite = $"./Sprite"

var game_stage: GameStage
var game_settings: GameSettings
var player_state: PlayerState

func _ready():
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")

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
	player_state.world_position = get_global_transform().origin;

	if (Input.is_action_pressed("player_change_spell_flare")):
		player_state.set_spell("flare")
	elif (Input.is_action_pressed("player_change_spell_gale")):
		player_state.set_spell("gale")
	elif (Input.is_action_pressed("player_change_spell_spike")):
		player_state.set_spell("spike")
	
func stage_ready():
	set_process(true)
	game_stage = owner;
	game_settings = game_stage.get_game_settings()
	player_state = game_stage.get_player_state()
