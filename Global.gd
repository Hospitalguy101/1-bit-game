extends Node

var DEADZONE = 0.1;

var players = [0, 0];

func _ready():
	for p in get_node("/root/Game/Players").get_children():
		if p.id == 0: players[0] = p;
		else: players[1] = p;

func _process(delta):
	pass
