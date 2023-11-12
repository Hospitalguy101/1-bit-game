extends RigidBody2D

class_name Fighter;

@export var run_speed = 1000.0;
@export var max_run_speed = 100.0;
@export var air_speed = 1500.0;
@export var max_air_speed = 100.0
var floored = true;

var hasDoubleJump = false;

var crouching = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity");

func _ready():
	pass;

func _physics_process(delta):
	rotation = 0;
	#Check if raycast is colliding with the floor
	if $FloorChecker.is_colliding() and $FloorChecker.get_collider().is_in_group("FloorCollider"):
		floored = true;
	else: floored = false;
	# Add the gravity.
#	if not floored:
#		apply_force(Vector2(0, gravity*delta));
	
	#momvement controls
	if floored:
		hasDoubleJump = true;
		if Input.is_action_pressed("move_left") and get_linear_velocity().x > -1*max_run_speed and !crouching:
			apply_force(Vector2(-1*run_speed, 0));
		if Input.is_action_pressed("move_right") and get_linear_velocity().x < max_run_speed and !crouching:
			apply_force(Vector2(run_speed, 0));
		if Input.is_action_just_pressed("jump"):
			set_axis_velocity(Vector2(0, -300));
		if Input.is_action_pressed("crouch"):
			crouching = true
		if Input.is_action_just_released("crouch"):
			crouching = false
	else:
		if Input.is_action_pressed("move_left") and get_linear_velocity().x > -1*max_air_speed:
			apply_force(Vector2(-1*air_speed, 0));
		if Input.is_action_pressed("move_right") and get_linear_velocity().x < max_air_speed:
			apply_force(Vector2(air_speed, 0));
		if Input.is_action_just_pressed("jump") and hasDoubleJump:
			set_axis_velocity(Vector2(0, -300));
			hasDoubleJump = false;
		if Input.is_action_pressed("crouch"):
			#fall twice as fast
			apply_force(Vector2(0, 1.5*gravity));

func _unhandled_input(event):
	var direction = Input.get_vector("move_left", "move_right", "crouch", "jump");
	if event.is_action_pressed("light_attack"):
		light_attack(direction);
	elif event.is_action_pressed("slash_attack"):
		slash_attack(direction);
	elif event.is_action_pressed("heavy_attack"):
		heavy_attack(direction);

func light_attack(direction):
	pass;
	
func slash_attack(direction):
	pass;

func heavy_attack(direction):
	pass;
