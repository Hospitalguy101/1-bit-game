extends Fighter

var chain_light = false;

var charging = false;
var charge_timer = 0;
var running_attack = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	#you may think this line is redundant since the collision mask is disabled in the editor.
	#It is LYING to you. I have no idea why but I guess Godot just decided it wants this guy colliding
	#with other players, so here we are.
	set_collision_mask_value(1, false);
	
	move_vars.append(false);
	


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _physics_process(delta):
	if crouching:
		$GPUParticles2D.set_position(Vector2(2, -7))
	else:
		$GPUParticles2D.set_position(Vector2(1, -11));
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
		print(charge_timer)
		$AttackTimers/LightChargeTimer.start(charge_timer);
		

func slash_attack(direction):
	#hard left
	if direction.x < -Global.DEADZONE and abs(direction.y) < Global.DEADZONE:
		$Hurtboxes/Windbox.activate(1.5);


func heavy_attack(direction):
	#hard down
	if abs(direction.x) < Global.DEADZONE and direction.y < -Global.DEADZONE:
		$AttackTimers/DownHeavyTimer.start(1);
		$Hurtboxes/DownHeavyHurtbox.top_level = true;
		$Hurtboxes/DownHeavyHurtbox.position += position;

func update_animation_param():
	pass


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
