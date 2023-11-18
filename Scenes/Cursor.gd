extends CharacterBody2D

var id
const SPEED = 40000.0
var isControl = false
var selected = false

var directionx
var directiony

func _ready():
	self.visible = false

func _process(delta):
	id = Global.players[0]
	if isControl:
		self.visible = true
		if ($RayCast2D.get_collider() == get_parent().get_node("RinProfile/RinArea")):
			get_parent().get_node("Rincharselect1").visible = true
		else:
			get_parent().get_node("Rincharselect1").visible = false
		if ($RayCast2D.get_collider() == get_parent().get_node("MachampProfile/MachampArea")):
			get_parent().get_node("Champcharselect1").visible = true
		else:
			get_parent().get_node("Champcharselect1").visible = false
		get_parent().get_node("ControllerIcon1").visible = false
		directionx = Input.get_joy_axis(Global.players[0], JOY_AXIS_LEFT_X)
		directiony = Input.get_joy_axis(Global.players[0], JOY_AXIS_LEFT_Y)
		move_and_slide()
		if selected:
			velocity = Vector2.ZERO
		else:
			velocity = velocity.move_toward(Vector2(directionx, directiony).normalized()*300, SPEED)

func _unhandled_input(event):
	if event.device != id: return;
	else:
		isControl = true
		if event.is_action_pressed("Select") and $RayCast2D.get_collider() == get_parent().get_node("RinProfile/RinArea"):
			selected = true
			print("selected")
			Global.playerOneChar = "Rin"
			get_parent().get_node("CharName1").text = "RIN"
		if event.is_action_pressed("Select") and $RayCast2D.get_collider() == get_parent().get_node("MachampProfile/MachampArea"):
			selected = true
			print("selected")
			Global.playerOneChar = "Caelum"
			get_parent().get_node("CharName1").text = "CAELUM"
		if selected == true and event.is_action_pressed("Deselect"):
			print("not static")
			selected = false
			Global.playerOneChar = ""
			get_parent().get_node("CharName1").text = ""
		
	

