extends CheckButton

var game_stage: GameStage;

func _ready():
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")

func _toggled(button_pressed):
	game_stage.get_game_settings().use_controller = button_pressed

func stage_ready():
	set_process(true)
	game_stage = owner as GameStage
	pressed = game_stage.get_game_settings().use_controller