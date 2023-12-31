extends RigidBody2D

class_name Fighter;

@export var id = 0;

@export var run_speed = 1000.0;
@export var max_run_speed = 100.0;
#@export var air_speed = 1500.0;
#@export var max_air_speed = 100.0
@export var jump_height = 150;

var floored = true;
var hasDoubleJump = false;
var crouching = false

var hp = 100;

var blocking = false;
var crouch_blocking = false;

var damage_modifier = 1;

var on_left = true;

var can_move = true;

var hitstun = false;
var blockstun = false;
var super_armor = false;
var knocked_down = false;
var fallen_over = false;

var invincible = false;

var dash_step = 0;
var dash_direction = 0;

var direction = Vector2.ZERO;

#true if player currently inputting a motion input
var motion_combo = false;
var current_special;
var special_step = 0;
var special_channel = false;

var in_grabbing_animation = false;

var has_grab = true;
var is_grabbed = false;
var grabbing = false;
var down_throw_point = Vector2.ZERO;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity");

#debug vars
@export var controllable = true;

var move_vars = [];

func _ready():
	pass;

func _physics_process(delta):
	direction = Vector2(Input.get_joy_axis(id, JOY_AXIS_LEFT_X), -Input.get_joy_axis(id, JOY_AXIS_LEFT_Y));
	
	get_node("/root/FightingGame/Game/Camera/UI/HP" + str(id+1)).value = hp;
	
	for p in Global.players:
		if p.id != id:
			if p.position.x < position.x:
				on_left = false;
				direction.x *= -1;
				scale.x *= -1;
			else:
				on_left = true;
				
	#ignore friction unless we aren't moving, also progress dash if stick is not moving
	if abs(direction.x) < 0.1:
		dash_direction = 0;
		if dash_step == 1: 
			dash_step = 2;
			$DashTimer.stop();
			$DashTimer.start(.3);
		if dash_step == 3:
			dash_step = 4;
			$DashTimer.stop();
			$DashTimer.start(.3)
		if linear_velocity.x != 0 and floored: apply_force(Vector2(-linear_velocity.x*mass*20, 0));
	
	rotation = 0;
	
	#Check if raycast is colliding with the floor
	if $FloorChecker.is_colliding() and $FloorChecker.get_collider().is_in_group("FloorCollider"):
		#check if player just hit floor
		if !floored:
			if knocked_down:
				knocked_down = false;
				fallen_over = true;
		floored = true;
	else: floored = false;
	#grab clashes
	if is_grabbed and !$Grabbox/ClashTimer.is_stopped():
		$Grabbox._on_grab_timer_timeout();
		if id == 0: Global.players[1]._on_grab_timer_timeout();
		else: Global.players[0]._on_grab_timer_timeout();
			
	can_move = !crouching and !is_grabbed and !grabbing and !hitstun and !blockstun;
	#check movement variables
	if move_vars.size() > 0 and can_move:
		for v in move_vars:
			if v:
				can_move = false;
				
	#blocking code
	blocking = false;
	crouch_blocking = false;
	if can_move and direction.x < -Global.DEADZONE: blocking = true;
	elif crouching and direction.x < -Global.DEADZONE: crouch_blocking = true;

func _unhandled_input(event):
	if event.device != id: return;
	#throw controls
	if grabbing and $Grabbox.active:
		if Input.is_action_pressed("p1_jump"):
			var thrown = $Grabbox.throw(0);
			if thrown: grabbing = false;
		if Input.is_action_pressed("p1_move_left"):
			var thrown = $Grabbox.throw(1);
			if thrown: grabbing = false;
		if Input.is_action_pressed("p1_crouch"):
			var thrown = $Grabbox.down_throw(down_throw_point);
			if thrown: grabbing = false;
		if Input.is_action_pressed("p1_move_right"):
			var thrown = $Grabbox.throw(2);
			if thrown: grabbing = false;
	
	
	#get up if fallen over
	if can_move and fallen_over:
		$GetUpTimer.start(.2);
		invincible = true;
		
	#momvement controls
	if floored and controllable and can_move:
		hasDoubleJump = true;
		if Input.is_action_pressed("p1_move_left"):
			if get_linear_velocity().x > -max_run_speed:
				if dash_step == 0: dash_step = 1;
				if dash_step == 2:
					dash_step = 0;
					apply_impulse(Vector2(-150, 0));
					$DashRecoil.start(.1);
					dash_direction = 1;
				apply_force(Vector2(-run_speed, 0));
		if Input.is_action_pressed("p1_move_right"):
			if get_linear_velocity().x < max_run_speed:
				if dash_step == 0: dash_step = 3;
				if dash_step == 4:
					dash_step = 0;
					apply_impulse(Vector2(150, 0));
					$DashRecoil.start(.1);
					dash_direction = -1;
				apply_force(Vector2(run_speed, 0));
		if Input.is_action_just_pressed("p1_jump"):
			#straight jump
			if direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE:
				set_axis_velocity(Vector2(0, -jump_height));
			#right jump
			elif direction.x > Global.DEADZONE:
				set_axis_velocity(Vector2(.1, -.9)*jump_height);
			#left jump
			elif direction.x < -Global.DEADZONE:
				set_axis_velocity(Vector2(-.1, -.9)*jump_height);
		if event.is_action_pressed("p1_crouch"):
			crouching = true;
		if event.is_action_released("p1_crouch"):
			crouching = false;
	elif controllable and !is_grabbed and can_move:
		if Input.is_action_just_pressed("p1_jump") and hasDoubleJump and !motion_combo:
			hasDoubleJump = false
			#straight jump
			if direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE:
				set_axis_velocity(Vector2(0, -jump_height));
			#right jump
			elif direction.x > Global.DEADZONE:
				set_axis_velocity(Vector2(.1, -.9)*jump_height);
			#left jump
			elif direction.x < -Global.DEADZONE:
				set_axis_velocity(Vector2(-.1, -.9)*jump_height);

		
	if !motion_combo and can_move and controllable:
		if event.is_action_pressed("p1_light_attack"):
			light_attack(direction);
		elif event.is_action_pressed("p1_slash_attack"):
			slash_attack(direction);
		elif event.is_action_pressed("p1_heavy_attack"):
			heavy_attack(direction);
		elif event.is_action_pressed("p1_grab") and has_grab:
			if get_node_or_null("GrabHand"):
				in_grabbing_animation = true;
			$Grabbox.grab();
			
			
		if event.is_action_released("p1_light_attack"):
			release_light_attack();
		elif event.is_action_released("p1_slash_attack"):
			release_slash_attack();
		elif event.is_action_released("p1_heavy_attack"):
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
	if special_channel:
		special_channel = false;
		special_step += 1;
	else:
		special_step += 1;
		$ComboTimer.stop();
		$ComboTimer.start(.6);
	
func progress_dash():
	dash_step += 1;
	$DashTimer.stop();
	$DashTimer.start(.6);

func _on_combo_timer_timeout():
	if special_channel: progress_combo();
	else: motion_combo = false;


func _on_stun_timer_timeout():
	blockstun = false;
	hitstun = false;


func _on_dash_timer_timeout():
	dash_step = 0;


#-1 = left, 1 = right
func _on_dash_recoil_timeout():
	apply_impulse(Vector2(dash_direction*150, 0));


func _on_get_up_timer_timeout():
	invincible = false;
