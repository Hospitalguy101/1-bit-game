extends RigidBody2D

class_name Fighter;

@export var id = 0;

@export var run_speed = 1000.0;
@export var max_run_speed = 100.0;
@export var air_speed = 1500.0;
@export var max_air_speed = 100.0
@export var jump_height = 150;

var floored = true;
var hasDoubleJump = false;
var crouching = false

var can_move = true;

var direction = Vector2.ZERO;
#true if player currently inputting a motion input
var motion_combo = false;
var current_special;
var special_step = 0;

var is_grabbed = false;
var grabbing = false;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity");

#debug vars
@export var controllable = true;

#0 = crouching
var move_vars = [false];

func _ready():
	pass;

func _physics_process(delta):
	direction = Input.get_vector("move_left", "move_right", "crouch", "jump");
	
	#ignore friction unless we aren't moving
	if abs(direction.x) < 0.1 and linear_velocity.x != 0 and floored: apply_force(Vector2(-linear_velocity.x*mass*20, 0));
	
	rotation = 0;
	#Check if raycast is colliding with the floor
	if $FloorChecker.is_colliding() and $FloorChecker.get_collider().is_in_group("FloorCollider"): floored = true;
	else: floored = false;
	
	
	#throw controls
	if grabbing and $Grabbox.active:
		if Input.is_action_pressed("jump"):
			$Grabbox.throw(0);
			grabbing = false;
		if Input.is_action_pressed("move_left"):
			$Grabbox.throw(1);
			grabbing = false;
		if Input.is_action_pressed("crouch"):
			$Grabbox.throw(2);
			grabbing = false;
		if Input.is_action_pressed("move_right"):
			$Grabbox.throw(3);
			grabbing = false;
			
	can_move = true;
	#check movement variables
	if move_vars.size() > 0:
		for v in move_vars:
			if v:
				can_move = false;
	#momvement controls
	if floored and controllable and can_move:
		hasDoubleJump = true;
		if Input.is_action_pressed("move_left") and get_linear_velocity().x > -max_run_speed:
			apply_force(Vector2(-run_speed, 0));
		if Input.is_action_pressed("move_right") and get_linear_velocity().x < max_run_speed:
			apply_force(Vector2(run_speed, 0));
		if Input.is_action_just_pressed("jump") and !motion_combo:
			set_axis_velocity(Vector2(0, -jump_height));
	elif controllable and !is_grabbed and can_move:
		if Input.is_action_pressed("move_left") and get_linear_velocity().x > -max_air_speed:
			apply_force(Vector2(-air_speed, 0));
		if Input.is_action_pressed("move_right") and get_linear_velocity().x < max_air_speed:
			apply_force(Vector2(air_speed, 0));
		if Input.is_action_just_pressed("jump") and hasDoubleJump and !motion_combo:
			set_axis_velocity(Vector2(0, -jump_height));
			hasDoubleJump = false;
		if Input.is_action_pressed("crouch"):
			#fall faster
			apply_force(Vector2(0, 1.5*gravity));

func _unhandled_input(event):
	if !motion_combo and controllable:
		if event.is_action_pressed("crouch"):
			crouching = true
			move_vars[0] = true;
		if event.is_action_released("crouch"):
			crouching = false
			move_vars[0] = false;
		
		if event.is_action_pressed("light_attack"):
			light_attack(direction);
		elif event.is_action_pressed("slash_attack"):
			slash_attack(direction);
		elif event.is_action_pressed("heavy_attack"):
			heavy_attack(direction);
		elif event.is_action_pressed("grab"):
			$Grabbox.grab();
			grabbing = true;
			
		if event.is_action_released("light_attack"):
			release_light_attack();
		elif event.is_action_released("slash_attack"):
			release_slash_attack();
		elif event.is_action_released("heavy_attack"):
			release_heavy_attack();

func light_attack(direction):
	pass;
	
func slash_attack(direction):
	pass;

func heavy_attack(direction):
	pass;
	
func release_light_attack():
	pass;
	
func release_slash_attack():
	pass;

func release_heavy_attack():
	pass;

func progress_combo():
	special_step += 1;
	$ComboTimer.stop();
	$ComboTimer.start(.6);

func _on_input_timer_timeout():
	motion_combo = false;
