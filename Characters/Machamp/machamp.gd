extends Fighter

var chain_light = false;

var charging = false;
var charge_timer = 0;
var running_attack = false;

var groundSlam = false
var S2 = false

var has_light = true;
var has_heavy = true;
var has_slash = true;

var special_enemy;

@onready var body : AnimationTree = $AnimationPlayer/BodyTree
@onready var sarm : AnimationTree = $SArmAnim/SArmTree
@onready var harm : AnimationTree = $HArmAnim/HArmTree
@onready var garm : AnimationTree = $GArmAnim/GArmTree
@onready var larm : AnimationTree = $LArmAnim/LArmTree
@onready var hand : AnimationTree = $HandPlayer/HandTree

# Called when the node enters the scene tree for the first time.
func _ready():
	#you may think this line is redundant since the collision mask is disabled in the editor.
	#It is LYING to you. I have no idea why but I guess Godot just decided it wants this guy colliding
	#with other players, so here we are.
	set_collision_mask_value(1, false);
	
	move_vars.append(false);

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(delta):
	if S2:
		$Hurtboxes/Windbox/Wind.visible = true
	else:
		$Hurtboxes/Windbox/Wind.visible = false
	if crouching:
		$Hair.set_position(Vector2(2, -7))
	else:
		$Hair.set_position(Vector2(1, -11));
		
	update_animation_param()
	if charging: charge_timer += delta;
	if running_attack: apply_force(Vector2(2000, 0));
	
	down_throw_point = position + Vector2(20, -20);
	
	
	#cancel special channel
	if motion_combo and special_channel and direction.y > -Global.DEADZONE:
		motion_combo = false;
		special_step = 0;
		special_channel = false;
		crouching = false;
	super._physics_process(delta);

func light_attack(direction):
	if !has_light: return;
	#hard down
	if direction.y < -Global.DEADZONE and direction.x < Global.DEADZONE and direction.x > -Global.DEADZONE and !charging:
		charging = true;
		move_vars[move_vars.size()-1] = true;
		charge_timer = 0;
	else:
		#first attack
		if !chain_light:
			$Hurtboxes/LightHurtbox.launch_trajectory = Vector2(120, -100);
		#second attack
		else:
			$Hurtboxes/LightHurtbox.launch_trajectory = Vector2(200, -110);
		$Hurtboxes/LightHurtbox.activate(.5);
		$AttackTimers/LightAttackTimer.start(1);
		chain_light = true;

func release_light_attack():
	if charging:
		clamp(charge_timer, 0, 1);
		charging = false;
		running_attack = true;
		super_armor = true;
		$Hurtboxes/ChargeHurtbox.activate()
		$AttackTimers/LightChargeTimer.start(charge_timer);
		

func slash_attack(direction):
	if !has_slash: return;
	#hard left
	if direction.x < -Global.DEADZONE and abs(direction.y) < Global.DEADZONE:
		$Hurtboxes/Windbox.activate(1.5);
		S2 = true
	
	#no direction
	elif abs(direction.x) < Global.DEADZONE and abs(direction.y) < Global.DEADZONE and !get_node_or_null("Tornado"):
		var tornado = load("res://Characters/Machamp/tornado.tscn").instantiate();
		tornado.top_level = true;
		if on_left:
			tornado.position = position + Vector2(20, 13);
			tornado.velocity = Vector2(.5, -.2).normalized()*50;
		else:
			tornado.position = position + Vector2(-20, 13);
			tornado.velocity = Vector2(-.5, -.2).normalized()*50;
		tornado.scale = Vector2(.2, .2);
		call_deferred("add_child", tornado);
		tornado.get_node("Hurtbox/Duration").wait_time = 1.2;
		tornado.get_node("Hurtbox/Duration").autostart = true;

func heavy_attack(direction):
	if !has_heavy: return;
	#hard down
	if abs(direction.x) < Global.DEADZONE and direction.y < -Global.DEADZONE:
		groundSlam = true
		$AttackTimers/DownHeavyTimer.start(1);
		$Hurtboxes/DownHeavyHurtbox.top_level = true;
		$Hurtboxes/DownHeavyHurtbox.position += position;
		
	#no direction
	elif abs(direction.x) < Global.DEADZONE and abs(direction.y) < Global.DEADZONE and !get_node_or_null("Lightning"):
		var lightning = load("res://Characters/Machamp/lightning.tscn").instantiate();
		lightning.top_level = true;
		if on_left: lightning.position = position + Vector2(20, 50);
		else: lightning.position = position + Vector2(-20, 50);
		lightning.velocity = Vector2(0, -150);
		call_deferred("add_child", lightning);
		lightning.get_node("Hurtbox/Duration").wait_time = .7;
		lightning.get_node("Hurtbox/Duration").autostart = true;
		lightning.get_node("MoveTimer").wait_time = .2;
		lightning.get_node("MoveTimer").autostart = true;


#0 = light, 1 = heavy, 2 = slash, 3 = grab
func special(arm):

	$Hurtboxes/SpecialHurtbox.top_level = true;
	$Hurtboxes/SpecialHurtbox.position += position;
	$Hurtboxes/SpecialHurtbox.activate(2);
	match arm:
		0:
			has_light = false;
			$LArm.hide();
		1:
			has_heavy = false;
			$HArm.hide();
		2:
			has_slash = false;
			$SArm.hide();
		3:
			has_grab = false;
			$GArm.hide();

func _unhandled_input(event):
	if motion_combo and !$ComboTimer.is_stopped() and special_channel and special_step < 2 and (event is InputEventJoypadButton or event is InputEventKey):
		motion_combo = false;
		special_step = 0;
		special_channel = false;
	if !motion_combo:
		#hard down
		if event is InputEventJoypadMotion and abs(direction.x) < Global.DEADZONE and direction.y < -Global.DEADZONE:
			special_step = 0;
			current_special = 1;
			motion_combo = true;
			special_channel = true;
			$ComboTimer.stop();
			$ComboTimer.start(1);
	else:
		match special_step:
			1:
				if event is InputEventJoypadMotion and abs(direction.x) < Global.DEADZONE and direction.y > Global.DEADZONE:
					progress_combo();
				elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
			2:
				if event is InputEventJoypadMotion and abs(direction.x) < Global.DEADZONE and direction.y < -Global.DEADZONE:
					progress_combo();
				elif event is InputEventJoypadButton or event is InputEventKey or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
						motion_combo = false;
			3:
				if event.is_action_pressed("p1_light_attack"):
					special(0);
				elif event.is_action_pressed("p1_heavy_attack"):
					special(1);
				elif event.is_action_pressed("p1_slash_attack"):
					special(2);
				elif event.is_action_pressed("p1_grab"):
					special(3);
				elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
	super._unhandled_input(event);


func update_animation_param():
	if running_attack:
		body["parameters/conditions/charge"] = true
		body["parameters/conditions/ncharge"] = false
		sarm["parameters/conditions/charge"] = true
		sarm["parameters/conditions/ncharge"] = false
		harm["parameters/conditions/charge"] = true
		harm["parameters/conditions/ncharge"] = false
		garm["parameters/conditions/charge"] = true
		garm["parameters/conditions/ncharge"] = false
		larm["parameters/conditions/charge"] = true
		larm["parameters/conditions/ncharge"] = false
	else:
		body["parameters/conditions/charge"] = false
		body["parameters/conditions/ncharge"] = true
		sarm["parameters/conditions/charge"] = false
		sarm["parameters/conditions/ncharge"] = true
		harm["parameters/conditions/charge"] = false
		harm["parameters/conditions/ncharge"] = true
		garm["parameters/conditions/charge"] = false
		garm["parameters/conditions/ncharge"] = true
		larm["parameters/conditions/charge"] = false
		larm["parameters/conditions/ncharge"] = true
		
	if Input.is_action_pressed("p1_light_attack") and !charging and !running_attack and has_light:
		if !chain_light:
			body["parameters/conditions/L1"] = true
			sarm["parameters/conditions/L1"] = true
			harm["parameters/conditions/L1"] = true
			garm["parameters/conditions/L1"] = true
			larm["parameters/conditions/L1"] = true
		else:
			body["parameters/conditions/L1"] = true
			sarm["parameters/conditions/L1"] = true
			harm["parameters/conditions/L1"] = true
			garm["parameters/conditions/L1"] = true
			larm["parameters/conditions/L2"] = true
	
	if groundSlam:
		body["parameters/conditions/GP"] = true
		sarm["parameters/conditions/GP"] = true
		harm["parameters/conditions/GP"] = true
		garm["parameters/conditions/GP"] = true
		larm["parameters/conditions/GP"] = true
		
	if S2:
		body["parameters/conditions/S2"] = true
		sarm["parameters/conditions/S2"] = true
		harm["parameters/conditions/S2"] = true
		garm["parameters/conditions/S2"] = true
		larm["parameters/conditions/S2"] = true
		
	if crouching:
		body["parameters/conditions/crouch"] = true
		body["parameters/conditions/ncrouch"] = false
		sarm["parameters/conditions/crouch"] = true
		sarm["parameters/conditions/ncrouch"] = false
		harm["parameters/conditions/crouch"] = true
		harm["parameters/conditions/ncrouch"] = false
		garm["parameters/conditions/crouch"] = true
		garm["parameters/conditions/ncrouch"] = false
		larm["parameters/conditions/crouch"] = true
		larm["parameters/conditions/ncrouch"] = false
	else:
		body["parameters/conditions/crouch"] = false
		body["parameters/conditions/ncrouch"] = true
		sarm["parameters/conditions/crouch"] = false
		sarm["parameters/conditions/ncrouch"] = true
		harm["parameters/conditions/crouch"] = false
		harm["parameters/conditions/ncrouch"] = true
		garm["parameters/conditions/crouch"] = false
		garm["parameters/conditions/ncrouch"] = true
		larm["parameters/conditions/crouch"] = false
		larm["parameters/conditions/ncrouch"] = true
		
	if Global.Grab:
		hand["parameters/conditions/grabEnd"] = false
		hand["parameters/conditions/form"] = true
	if Global.Grabbed:
		hand["parameters/conditions/grab"] = true
	elif Global.throwingDown:
		hand["parameters/conditions/smack"] = true
	else:
		hand["parameters/conditions/grab"] = false
		hand["parameters/conditions/smack"] = false
		
func _on_light_attack_timer_timeout():
	chain_light = false;


func _on_light_charge_timer_timeout():
	running_attack = false;
	move_vars[move_vars.size()-1] = false;
	super_armor = false;
	$Hurtboxes/ChargeHurtbox.deactivate()
	


func _on_down_heavy_timer_timeout():
	$Hurtboxes/DownHeavyHurtbox.activate(.4);
	$Hurtboxes/DownHeavyHurtbox.top_level = false;
	$Hurtboxes/DownHeavyHurtbox.position -= position;


func _on_charge_hurtbox_enemy_hit(enemy):
	linear_velocity.x = 0;
	_on_light_charge_timer_timeout();
	$AttackTimers/LightChargeTimer.stop();


func _on_body_tree_animation_finished(anim_name):
	body["parameters/conditions/L1"] = false
	sarm["parameters/conditions/L1"] = false
	harm["parameters/conditions/L1"] = false
	garm["parameters/conditions/L1"] = false
	larm["parameters/conditions/L1"] = false
	if groundSlam:
		groundSlam = false
		body["parameters/conditions/GP"] = false
		sarm["parameters/conditions/GP"] = false
		harm["parameters/conditions/GP"] = false
		garm["parameters/conditions/GP"] = false
		larm["parameters/conditions/GP"] = false
	if S2:
		S2 = false
		body["parameters/conditions/S2"] = false
		sarm["parameters/conditions/S2"] = false
		harm["parameters/conditions/S2"] = false
		garm["parameters/conditions/S2"] = false
		larm["parameters/conditions/S2"] = false
		
func _on_hand_tree_animation_finished(anim_name):
	if !Global.Grabbed:
		hand["parameters/conditions/grabEnd"] = true
		hand["parameters/conditions/form"] = false
		


func _on_special_hurtbox_enemy_hit(enemy):
	special_enemy = enemy;
	enemy.sleeping = true; #TODO: TEST SLEEPING, PROB WONT WORK


func _on_duration_timeout():
	if special_enemy: special_enemy.sleeping = false;
	special_enemy = null;
