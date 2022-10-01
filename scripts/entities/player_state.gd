class_name PlayerState extends Resource;


signal spell_has_changed(new_spell)

export var world_position: Vector2 = Vector2.ZERO;
export var health: int = 7;
export var max_health: int = 7;
export var current_spell: String = "gale";

func _ready():
	health = max_health

func set_spell(spell_name: String):
	print("changed spell to %s" % spell_name)
	current_spell = spell_name
	emit_signal("spell_has_changed", spell_name)