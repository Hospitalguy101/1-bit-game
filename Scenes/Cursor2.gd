extends CharacterBody2D

var id
const SPEED = 40000.0
var isControl = false
var selected = false

func _ready():
	self.visible = false

func _process(delta):
	id = Global.players[1]
	if isControl:
		get_parent().get_node("ControllerIcon2").visible = false
		self.visible = true
		var directionx = Input.get_joy_axis(Global.players[1], JOY_AXIS_LEFT_X)
		var directiony = Input.get_joy_axis(Global.players[1], JOY_AXIS_LEFT_Y)
		velocity = velocity.move_toward(Vector2(directionx, directiony).normalized()*300, SPEED)
		move_and_slide()
		
func _unhandled_input(event):
	if event.device != id: return;
	else:
		if selected == false:
			isControl = true
	

