extends KinematicBody2D

enum Awareness {
	ALERT = 0,
	AWARE = 1,
	UNAWARE = 2
}

enum ActivityState {
	ACTIVE = 0,
	DEAD = 1,
	STUNNED = 2
}

export var brain_resource: Resource
export var enemy_speed: float = 75.0;

export var awareness = Awareness.UNAWARE
export var state = ActivityState.ACTIVE

export var can_see_player: bool = false

onready var sprite: Sprite = $"./Sprite" 
onready var player_search_raycast: RayCast2D = $"./PlayerSearchRayCast"
var awareness_visuals: Dictionary = {};

var stun_timer: float;
var shove_speed: float;
var shove_target_position: Vector2;

var enemy_brain: EnemyBrainBase
var game_stage: GameStage
var player_state: PlayerState

func _ready():
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")

	awareness_visuals[Awareness.ALERT] = $"./AwarenessContainter/Alert"
	awareness_visuals[Awareness.AWARE] = $"./AwarenessContainter/Aware"
	awareness_visuals[Awareness.UNAWARE] = $"./AwarenessContainter/Unaware"
	update_awareness_value();

func stage_ready():
	set_process(true)
	game_stage = (owner as GameStage)
	player_state = game_stage.get_player_state()

	if (brain_resource == null || !brain_resource is EnemyBrainBase):
		brain_resource = EnemyBrainBase.new()
	
	enemy_brain = brain_resource as EnemyBrainBase;
	enemy_brain.on_stage_ready(game_stage, self)

func _physics_process(delta):
	if state == ActivityState.DEAD:
		get_parent().remove_child(self)
		return


	if state == ActivityState.STUNNED:
		stun_timer -= delta
		shove_speed -= delta * shove_speed / 2

		if (shove_target_position.distance_to(position) > 1):
			var vec = position.direction_to(shove_target_position);
			translate(move_and_slide(vec * shove_speed * delta))

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

	if (awareness == Awareness.UNAWARE):
		process_unaware_state()
	elif (awareness == Awareness.AWARE):
		process_aware_state()
	elif (awareness == Awareness.ALERT):
		process_alert_state()
	
	var desired_movement = enemy_brain.get_desired_poisition() - position
	if (desired_movement.length() > 16.0): #wpx2022 TODO: this should come from const but is basically equal to entity size
		var movement_vector = desired_movement.normalized()

		if movement_vector.x < 0:
			sprite.flip_h = true
		elif movement_vector.x > 0:
			sprite.flip_h = false

		translate(move_and_slide(movement_vector * enemy_speed * delta))

	update_awareness_value();

func do_damage(damage_amount: int, damage_source: String):
	if enemy_brain.take_damage(damage_amount, damage_source):
		state = ActivityState.DEAD;


func shove(origin: Vector2, distance: float, speed: float, stun_duration: float):

	print("%s was shoved" % name)

	var direction_from_point = origin.direction_to(position)
	shove_target_position = direction_from_point.normalized() * distance;
	awareness = Awareness.UNAWARE
	state = ActivityState.STUNNED
	shove_speed = speed
	stun_timer = stun_duration
	update_awareness_value()

func process_unaware_state():
	enemy_brain.process_unaware_state()

	if can_see_player:
		awareness = Awareness.AWARE

func process_aware_state():
	enemy_brain.process_aware_state()

	if !can_see_player:
		awareness = Awareness.ALERT

func process_alert_state():
	enemy_brain.process_alert_state()

	if can_see_player:
		awareness = Awareness.AWARE

func update_awareness_value():
	for awareness_visual in awareness_visuals.values():
		awareness_visual.visible = (awareness_visual == awareness_visuals[awareness])