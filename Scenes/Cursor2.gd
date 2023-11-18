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
	id = Global.device_ids[1]
	if isControl:
		self.visible = true
		if ($RayCast2D.get_collider() == get_parent().get_node("RinProfile/RinArea")):
			get_parent().get_node("Rincharselect2").visible = true
		else:
			get_parent().get_node("Rincharselect2").visible = false
		if ($RayCast2D.get_collider() == get_parent().get_node("MachampProfile/MachampArea")):
			get_parent().get_node("Champcharselect2").visible = true
		else:
			get_parent().get_node("Champcharselect2").visible = false
		get_parent().get_node("ControllerIcon2").visible = false
		directionx = Input.get_joy_axis(Global.device_ids[1], JOY_AXIS_LEFT_X)
		directiony = Input.get_joy_axis(Global.device_ids[1], JOY_AXIS_LEFT_Y)
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
			Global.playerOneChar = "Rin"
			get_parent().get_node("CharName2").text = "RIN"
		if event.is_action_pressed("Select") and $RayCast2D.get_collider() == get_parent().get_node("MachampProfile/MachampArea"):
			selected = true
			Global.playerOneChar = "Caelum"
			get_parent().get_node("CharName2").text = "CAELUM"
		if selected == true and event.is_action_pressed("Deselect"):
			selected = false
			Global.playerOneChar = ""
			get_parent().get_node("CharName2").text = ""
		
