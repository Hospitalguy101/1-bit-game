extends Fighter

var chain_light = false;

var charging = false;
var charge_timer = 0;
var running_attack = false;

var groundSlam = false
var S2 = false

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
	
	super._physics_process(delta);

func light_attack(direction):
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
	#hard left
	if direction.x < -Global.DEADZONE and abs(direction.y) < Global.DEADZONE:
		$Hurtboxes/Windbox.activate(1.5);
		S2 = true


func heavy_attack(direction):
	#hard down
	if abs(direction.x) < Global.DEADZONE and direction.y < -Global.DEADZONE:
		groundSlam = true
		$AttackTimers/DownHeavyTimer.start(1);
		$Hurtboxes/DownHeavyHurtbox.top_level = true;
		$Hurtboxes/DownHeavyHurtbox.position += position;

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
		
	if Input.is_action_pressed("p1_light_attack") and !charging and !running_attack:
		body["parameters/conditions/L1"] = true
		sarm["parameters/conditions/L1"] = true
		harm["parameters/conditions/L1"] = true
		garm["parameters/conditions/L1"] = true
		larm["parameters/conditions/L1"] = true
	
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
		
