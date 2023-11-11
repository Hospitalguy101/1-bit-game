extends CharacterBody2D

class_name character;

@export var walk_speed = 200;
@export var run_speed = 300.0;
@export var air_speed = 300.0;

var hasDoubleJump = false;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity");

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta;
	
	#momvement controls
	if is_on_floor():
		hasDoubleJump = true;
		if Input.is_action_pressed("move_left"):
			velocity.x = -1*run_speed;
		if Input.is_action_pressed("move_right"):
			velocity.x = run_speed;
		if Input.is_action_just_pressed("jump"):
			velocity.y = 100;
		if Input.is_action_pressed("crouch"):
			#crouch animation
			pass
	else:
		if Input.is_action_pressed("move_left"):
			velocity.x = -1*air_speed;
		if Input.is_action_pressed("move_right"):
			velocity.x = air_speed;
		if Input.is_action_just_pressed("jump") and hasDoubleJump:
			velocity.y = 100;
			hasDoubleJump = false;
		if Input.is_action_pressed("crouch"):
			#fall twice as fast
			velocity.y += gravity*delta
		
	move_and_slide();
