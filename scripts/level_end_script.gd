extends Area2D

var game_stage: GameStage

func _ready():
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")

func stage_ready():
	set_process(true)
	game_stage = (owner as GameStage)

func _process(_delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		print(body)
		if body.name == "Player":
			game_stage.player_entered_exit()
			get_parent().remove_child(self)