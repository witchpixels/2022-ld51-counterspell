class_name EnemyBrainBase extends Resource

var stage: GameStage
var owner_body: KinematicBody2D
var last_known_player_position: Vector2

func on_stage_ready(game_stage: GameStage, owner: KinematicBody2D):
    stage = game_stage;
    owner_body = owner;

func process_unaware_state():
    last_known_player_position = owner_body.position

func process_aware_state():
    last_known_player_position = stage.get_player_state().world_position

func process_alert_state():
    pass;

func get_desired_poisition() -> Vector2:
    return last_known_player_position;