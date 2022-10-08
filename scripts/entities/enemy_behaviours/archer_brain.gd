extends EnemyBrainBase

export var arrow_range: int = 256
export var arrow_template: PackedScene

var can_shoot: bool = false

func on_stage_ready(game_stage: GameStage, owner: KinematicBody2D):
	.on_stage_ready(game_stage, owner)
	var _i = game_stage.get_timer().connect("timeout", self, "_on_timer_timeout")

func process_aware_state():
	.process_aware_state()
	if (last_known_player_position.distance_to(owner_body.position) > arrow_range):
		desired_position = owner_body.position.direction_to(last_known_player_position) * 0.6 * arrow_range 
	else:
		desired_position = owner_body.position

func try_attack():
	if current_awareness != Awareness.AWARE:
		return
	
	if (last_known_player_position.distance_to(owner_body.position) <= arrow_range
		&& can_shoot):
		can_shoot = false
		var arrow = arrow_template.instance() as KinematicBody2D
		arrow.position = owner_body.position
		arrow.rotation_degrees = rad2deg(owner_body.position.direction_to(last_known_player_position).angle())
		arrow.add_collision_exception_with(owner_body)
		owner_body.get_parent().add_child(arrow)
		attack_sound.play()

func _on_timer_timeout():
	can_shoot = true