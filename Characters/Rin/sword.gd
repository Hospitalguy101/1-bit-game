extends CharacterBody2D

var id = 0;
var isReady = true;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_and_slide()

#default traj is for default light attack
func initialize(time, traj=null, h=0, start_now=true):
	if traj: $Hurtbox.launch_trajectory = traj;
	$Hurtbox.height = h;
	
	#attack timer determines how long sword will exist before disappearing
	if start_now: start_timer(time);
	$Hurtbox.id = id;
	
func start_timer(time):
	$AttackTimer.wait_time = time;
	$AttackTimer.autostart = true;

func _on_attack_timer_timeout():
	call_deferred("queue_free");

func _on_hurtbox_body_entered(body):
	if body.is_in_group("FloorCollider"): velocity = Vector2.ZERO;
