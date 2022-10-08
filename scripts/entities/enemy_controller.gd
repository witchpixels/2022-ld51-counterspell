extends KinematicBody2D

enum ActivityState {
	ACTIVE = 0,
	DEAD = 1,
	STUNNED = 2
}

export var enemy_speed: float = 75.0
export var distance_to_player_tick_condition: float = 1024
export var unaware_tick_rate_seconds: float = 1
export var alert_tick_rate_seconds: float = 0.5

export var awareness = EnemyBrainBase.Awareness.UNAWARE
export var state = ActivityState.ACTIVE
export var can_see_player: bool = false

onready var sprite: Sprite = $"./Sprite" 
onready var player_search_raycast: RayCast2D = $"./PlayerSearchRayCast"
onready var enemy_brain: EnemyBrainBase = $"./Brain"
var awareness_visuals: Dictionary = {}

var was_stunned_this_cycle: bool = false
var tick_cooldown = 0
var distance_to_player_tick_condition_squared = 0

var game_stage: GameStage
var player_state: PlayerState

func _ready():
	set_process(false)

	distance_to_player_tick_condition_squared = distance_to_player_tick_condition * distance_to_player_tick_condition
	tick_cooldown = unaware_tick_rate_seconds
	awareness_visuals[EnemyBrainBase.Awareness.ALERT] = $"./AwarenessContainter/Alert"
	awareness_visuals[EnemyBrainBase.Awareness.AWARE] = $"./AwarenessContainter/Aware"
	awareness_visuals[EnemyBrainBase.Awareness.UNAWARE] = $"./AwarenessContainter/Unaware"
	
	var _i = owner.connect("ready", self, "stage_ready")

func stage_ready():
	game_stage = (owner as GameStage)
	player_state = game_stage.get_player_state()
	enemy_brain.on_stage_ready(game_stage, self)
	game_stage.get_timer().connect("timeout", self, "_on_timer_timeout")

	set_process(true)

func _physics_process(delta):
	if state == ActivityState.DEAD:
		get_parent().remove_child(self)
		return

	if state == ActivityState.STUNNED:
		return

	if player_state.world_position.distance_squared_to(position) > distance_to_player_tick_condition_squared:
		return

	var desired_movement = enemy_brain.get_desired_poisition() - position
	if (desired_movement.length() > 16.0): #wpx2022 TODO: this should come from const but is basically equal to entity size
		var movement_vector = desired_movement.normalized()

		if movement_vector.x < 0:
			sprite.flip_h = true
		elif movement_vector.x > 0:
			sprite.flip_h = false

		translate(move_and_slide(movement_vector * enemy_speed * delta))

	if tick_cooldown >= 0:
		tick_cooldown -= delta
		return


	player_search_raycast.cast_to = player_state.world_position - position
	player_search_raycast.force_raycast_update()
	if player_search_raycast.is_colliding():
		var collider = player_search_raycast.get_collider() as CollisionObject2D
		if collider:
			can_see_player = collider.get_collision_mask_bit(2)
		else:
			can_see_player = false
	else:
		can_see_player = false

	if (awareness == EnemyBrainBase.Awareness.UNAWARE):
		process_unaware_state()
		tick_cooldown = unaware_tick_rate_seconds
	elif (awareness == EnemyBrainBase.Awareness.AWARE):
		process_aware_state()
		tick_cooldown = 0
	elif (awareness == EnemyBrainBase.Awareness.ALERT):
		process_alert_state()
		tick_cooldown = alert_tick_rate_seconds

	enemy_brain.try_attack()
	update_awareness_value()

func do_damage(damage_amount: int, damage_source: String):
	if enemy_brain.take_damage(damage_amount, damage_source):
		state = ActivityState.DEAD

func _on_timer_timeout():
	if state == ActivityState.STUNNED:
		if was_stunned_this_cycle:
			was_stunned_this_cycle = false
		else:
			state = ActivityState.ACTIVE

func stun():
	state = ActivityState.STUNNED
	awareness = EnemyBrainBase.Awareness.UNAWARE
	tick_cooldown = unaware_tick_rate_seconds
	was_stunned_this_cycle = true
	update_awareness_value()

func process_unaware_state():
	enemy_brain.process_unaware_state()

	if can_see_player:
		awareness = EnemyBrainBase.Awareness.AWARE
		tick_cooldown = 0

func process_aware_state():
	enemy_brain.process_aware_state()

	if !can_see_player:
		awareness = EnemyBrainBase.Awareness.ALERT
		tick_cooldown = alert_tick_rate_seconds

func process_alert_state():
	enemy_brain.process_alert_state()

	if can_see_player:
		awareness = EnemyBrainBase.Awareness.AWARE
		tick_cooldown = 0

func update_awareness_value():
	for awareness_visual in awareness_visuals.values():
		awareness_visual.visible = (awareness_visual == awareness_visuals[awareness])
