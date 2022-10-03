extends KinematicBody2D

enum ActivityState {
	ACTIVE = 0,
	DEAD = 1,
	STUNNED = 2
}

export var enemy_speed: float = 75.0;

export var awareness = EnemyBrainBase.Awareness.UNAWARE
export var state = ActivityState.ACTIVE

export var can_see_player: bool = false

onready var sprite: Sprite = $"./Sprite" 
onready var player_search_raycast: RayCast2D = $"./PlayerSearchRayCast"
onready var enemy_brain: EnemyBrainBase = $"./Brain"
var awareness_visuals: Dictionary = {};

var stun_timer: float;

var game_stage: GameStage
var player_state: PlayerState

func _ready():
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")

	awareness_visuals[EnemyBrainBase.Awareness.ALERT] = $"./AwarenessContainter/Alert"
	awareness_visuals[EnemyBrainBase.Awareness.AWARE] = $"./AwarenessContainter/Aware"
	awareness_visuals[EnemyBrainBase.Awareness.UNAWARE] = $"./AwarenessContainter/Unaware"

func stage_ready():
	set_process(true)
	game_stage = (owner as GameStage)
	player_state = game_stage.get_player_state()
	enemy_brain.on_stage_ready(game_stage, self)

func _physics_process(delta):
	if state == ActivityState.DEAD:
		get_parent().remove_child(self)
		return


	if state == ActivityState.STUNNED:
		stun_timer -= delta

		if stun_timer <= 0:
			state = ActivityState.ACTIVE
		return;


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
	elif (awareness == EnemyBrainBase.Awareness.AWARE):
		process_aware_state()
	elif (awareness == EnemyBrainBase.Awareness.ALERT):
		process_alert_state()
	
	var desired_movement = enemy_brain.get_desired_poisition() - position
	if (desired_movement.length() > 16.0): #wpx2022 TODO: this should come from const but is basically equal to entity size
		var movement_vector = desired_movement.normalized()

		if movement_vector.x < 0:
			sprite.flip_h = true
		elif movement_vector.x > 0:
			sprite.flip_h = false

		translate(move_and_slide(movement_vector * enemy_speed * delta))

	enemy_brain.try_attack()
	update_awareness_value();

func do_damage(damage_amount: int, damage_source: String):
	if enemy_brain.take_damage(damage_amount, damage_source):
		state = ActivityState.DEAD;


func stun(stun_duration: float):

	print("%s was stunned" % name)
	stun_timer = stun_duration
	state = ActivityState.STUNNED
	awareness = EnemyBrainBase.Awareness.UNAWARE
	update_awareness_value()

func process_unaware_state():
	enemy_brain.process_unaware_state()

	if can_see_player:
		awareness = EnemyBrainBase.Awareness.AWARE

func process_aware_state():
	enemy_brain.process_aware_state()

	if !can_see_player:
		awareness = EnemyBrainBase.Awareness.ALERT

func process_alert_state():
	enemy_brain.process_alert_state()

	if can_see_player:
		awareness = EnemyBrainBase.Awareness.AWARE

func update_awareness_value():
	for awareness_visual in awareness_visuals.values():
		awareness_visual.visible = (awareness_visual == awareness_visuals[awareness])