extends Node

var DEADZONE = 0.3;

var color_modifier = 1;
var color = Color.WHITE;

var throwingDown = false

var playerOneWins = 0
var playerTwoWins = 0

var playerOneChar
var playerTwoChar

var volume;

var players = [2, 2];
var device_ids = [2, 2];

func _ready():
	pass

func _process(delta):
	#volume = get_node("/root/Fighting Game/TitleScreen/OptionsMenu/Volume/VolumeLabel").value;
	
	match color_modifier:
		1:
			color = Color.WHITE;
		2:
			color = Color.ORANGE;
		3:
			color = Color.INDIAN_RED;
		.5:
			color = Color.SEA_GREEN;
		.25:
			color = Color.CORNFLOWER_BLUE;
		0:
			color = Color.MEDIUM_PURPLE;
	
	#get_node("/root/FightingGame").set_modulate(color)
