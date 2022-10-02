class_name EnemyBrainBase extends Resource

export var corpse: PackedScene;
export var attack_damage: int = 1;

var stage: GameStage
var owner_body: KinematicBody2D
var last_known_player_position: Vector2


func on_stage_ready(game_stage: GameStage, owner: KinematicBody2D):
    stage = game_stage;
    owner_body = owner;

    stage.timer.connect("timeout", self, "_on_timer_up")


func process_unaware_state():
    last_known_player_position = owner_body.position

func process_aware_state():
    last_known_player_position = stage.get_player_state().world_position

func process_alert_state():
    pass;

func get_desired_poisition() -> Vector2:
    return last_known_player_position;

func _on_timer_up():
    if (owner_body.position.distance_to(stage.get_player_state().world_position) < 48):
        print("%s was able to attack player" % owner_body.name)
        stage.get_player_state().damage_player(attack_damage);

func take_damage(_amount: int, _source: String) -> bool:
    stage.timer.disconnect("timeout", self, "_on_timer_up")
    var corpse_instance = corpse.instance() as Node2D;
    corpse_instance.position = owner_body.position
    owner_body.get_parent().add_child(corpse_instance)

    return true;