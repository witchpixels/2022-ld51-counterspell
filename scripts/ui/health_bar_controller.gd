extends CenterContainer

onready var life_bar: Label = $"./MaxLifeBar/LifeBar"
onready var max_life_bar: Label = $"./MaxLifeBar"

var player_state: PlayerState

func _ready():
	set_process(false)
	var _i = owner.connect("ready", self, "stage_ready")

func _process(_delta):
	life_bar.visible_characters = player_state.health;
	max_life_bar.visible_characters = player_state.max_health;

func stage_ready():
	set_process(true)
	var game_stage = (owner as GameStage)
	player_state = game_stage.get_player_state()
