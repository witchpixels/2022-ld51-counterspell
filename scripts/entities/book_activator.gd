extends Area2D

var game_stage: GameStage
var obtained: bool = false

func _ready():
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")

func stage_ready():
	set_process(true)
	game_stage = (owner as GameStage)

func on_book_obtained():
	obtained = true

func _process(_delta):
	if obtained:
		return

	var bodies = get_overlapping_bodies()
	for body in bodies:
		print(body)
		if body.name == "Player":
			game_stage.player_obtained_book()
			get_parent().remove_child(self)