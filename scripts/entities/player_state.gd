class_name PlayerState extends Resource;

signal spell_has_changed(new_spell)
signal player_killed()

export var world_position: Vector2 = Vector2.ZERO;
export var health: int = 2;
export var max_health: int = 7;
export var current_spell: String = "gale";
export var iframes_duration: float = 5.0

export var in_iframes: bool = false;

var player_body: KinematicBody2D;

func _ready():
	health = max_health

func damage_player(damage: int):
	if in_iframes:
		return

	health -= damage;

	if health <= 0:
		emit_signal("player_killed")
		return

	in_iframes = true;

	var timer = player_body.get_tree().create_timer(iframes_duration, false)
	timer.connect("timeout", self, "_iframes_over")


func set_spell(spell_name: String):
	if (spell_name != current_spell):
		print("changed spell to %s" % spell_name)
		current_spell = spell_name
		emit_signal("spell_has_changed", spell_name)


func _iframes_over():
	in_iframes = false