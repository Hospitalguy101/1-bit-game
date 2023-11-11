extends CharacterBody2D

class_name Fighter;

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
			velocity.y = -500;
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
	if Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
		velocity.x = 0;
	move_and_slide();

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
