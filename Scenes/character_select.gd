extends Node2D

const MAX_MOUSE_SPEED = 25
var i
var read = false

# Called when the node enters the scene tree for the first time.
func _ready():
	i = 0
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Cursor.selected == true and $Cursor2.selected == true:
		read = true
		$PressStart.visible = true
	else:
		$PressStart.visible = false

func _unhandled_input(event):
	#if Input.is_action_just_pressed("p1_jump"):
		#$RayCast2D.get_collider()
	if Input.is_action_just_pressed("Start") and read == true:
		var game = load("res://Scenes/game.tscn").instantiate();
		var p1;
		var p2;
		
		match Global.playerOneChar:
			"Rin":
				p1 = load("res://Characters/Rin/rin.tscn").instantiate();
			"Caelum":
				p1 = load("res://Characters/Machamp/machamp.tscn").instantiate();
		
		if p2:
			match Global.playerTwoChar:
				"Rin":
					p2 = load("res://Characters/Rin/rin.tscn").instantiate();
				"Caelum":
					p2 = load("res://Characters/Machamp/machamp.tscn").instantiate();
		#if !p2: p2 = load("res://Characters/Rin/rin.tscn").instantiate();
		p1.id = 0;
		p2.id = 1;
		Global.players[0] = p1;
		Global.players[1] = p2;
		
		get_parent().get_node("SFX").stop();
		get_parent().get_parent().call_deferred("add_child", game);
		get_parent().call_deferred("queue_free");
	if Input.is_action_pressed("bumper_L") and Input.is_action_pressed("bumper_R") and i < 2:
		if i == 1:
			if event.device == Global.device_ids[0]:
				pass
			else:
				Global.device_ids[i] = event.device;
				i += 1
		else:
			Global.device_ids[i] = event.device;
			i += 1
	
