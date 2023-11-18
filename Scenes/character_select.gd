extends Node2D

const MAX_MOUSE_SPEED = 25
var i

# Called when the node enters the scene tree for the first time.
func _ready():
	i = 0
	print(Global.players)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	#if Input.is_action_just_pressed("p1_jump"):
		#$RayCast2D.get_collider()
	if Input.is_action_just_pressed("bumper_L") and Input.is_action_just_pressed("bumper_R") and i < 2:
		if i == 1:
			if event.device == Global.players[0]:
				pass
			else:
				Global.players[i] = event.device
				print(Global.players[i])
				i += 1
		else:
			Global.players[i] = event.device
			print(Global.players[i])
			i += 1
