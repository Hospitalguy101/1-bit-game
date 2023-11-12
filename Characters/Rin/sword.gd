extends CharacterBody2D

var id = 0;
var isReady = true;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_and_slide()

#default traj is for default light attack
func initialize(time, traj=null, height=0):
	id = get_parent().get_parent().id
	$Hurtbox.id = id;
	if traj: $Hurtbox.launch_trajectory = traj;
	
	#attack timer determines how long sword will exist before disappearing
	$AttackTimer.start(time);

func _on_attack_timer_timeout():
	queue_free();
