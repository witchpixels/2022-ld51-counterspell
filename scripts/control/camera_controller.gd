extends Camera2D

export var camera_speed: float = 1.0
export var wander_radius: float = 100
export var camera_zoom_speed: float = 1
export var camera_death_zoom_target: float = 1
export var camera_living_zoom_target: float = 1

export var max_look_distance: float = 96

onready var player: KinematicBody2D = $"%Player"
var camera_zoom_target: float = -1

var game_settings: GameSettings


func _ready():
	camera_zoom_target = camera_living_zoom_target
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")

func _physics_process(delta):
	var aiming_vector = Vector2.ZERO
	var look_distance = max_look_distance

	if game_settings.use_controller:
		aiming_vector = Vector2(
			Input.get_axis("player_aim_left", "player_aim_right"),
			Input.get_axis("player_aim_up", "player_aim_down")).normalized()
	else:
		aiming_vector = player.position.direction_to(get_global_mouse_position())
		look_distance = min(max_look_distance, player.position.distance_to(get_global_mouse_position()))

	var ideal_positon = player.position + aiming_vector * look_distance


	if (ideal_positon - position).length() > wander_radius:
		position = lerp(position, ideal_positon, delta * camera_speed).round()

	var current_zoom = zoom.x
	if current_zoom - camera_zoom_target > 0.0001:
		current_zoom = lerp(current_zoom, camera_zoom_target, camera_zoom_speed * delta)
		zoom.x = current_zoom
		zoom.y = current_zoom



func stage_ready():
	set_process(true)
	var game_stage = owner as GameStage

	game_settings = game_stage.get_game_settings()

	var player_state = game_stage.get_player_state()
	player_state.connect("player_killed", self, "_on_player_killed")

func _on_player_killed():
	wander_radius = 0
	camera_speed = camera_zoom_speed
	camera_zoom_target = camera_death_zoom_target



