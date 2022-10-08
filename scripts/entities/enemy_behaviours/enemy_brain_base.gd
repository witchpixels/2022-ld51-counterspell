class_name EnemyBrainBase extends Node

enum Awareness {
	ALERT = 0,
	AWARE = 1,
	UNAWARE = 2
}


onready var attack_animation: AnimatedSprite = $"./AttackAnimation"
onready var attack_sound: AudioStreamPlayer2D = $"./AttackSound"

export var corpse: PackedScene
export var attack_damage: int = 1

var stage: GameStage
var owner_body: KinematicBody2D
var last_known_player_position: Vector2
var desired_position: Vector2
var current_awareness: int = Awareness.UNAWARE

func _ready():
    attack_animation.frame = attack_animation.frames.get_frame_count("default")

func on_stage_ready(game_stage: GameStage, owner: KinematicBody2D):
    stage = game_stage
    owner_body = owner

func process_unaware_state():
    current_awareness = Awareness.UNAWARE
    last_known_player_position = owner_body.position
    desired_position = owner_body.position

func process_aware_state():
    current_awareness = Awareness.AWARE
    last_known_player_position = stage.get_player_state().world_position
    desired_position = last_known_player_position

func process_alert_state():
    current_awareness = Awareness.ALERT
    desired_position = last_known_player_position

func get_desired_poisition() -> Vector2:
    return desired_position

func try_attack():
    if current_awareness != Awareness.AWARE:
        return

    if (owner_body.position.distance_to(stage.get_player_state().world_position) < 48
        && !stage.get_player_state().in_iframes):
        attack_animation.position = owner_body.position
        attack_animation.frame = 0
        attack_sound.position = owner_body.position
        attack_sound.play()
        stage.get_player_state().damage_player(attack_damage)

func take_damage(_amount: int, _source: String) -> bool:
    var corpse_instance = corpse.instance() as Node2D
    corpse_instance.position = owner_body.position
    owner_body.get_parent().add_child(corpse_instance)

    return true