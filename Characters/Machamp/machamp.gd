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
		$Hurtboxes/ChargeHurtbox.activate()
		print(charge_timer)
		$AttackTimers/LightChargeTimer.start(charge_timer);

func update_animation_param():
	pass


func _on_light_attack_timer_timeout():
	chain_light = false;


func _on_light_charge_timer_timeout():
	running_attack = false;
	move_vars[move_vars.size()-1] = false;
	$Hurtboxes/ChargeHurtbox.deactivate()
