extends Area2D

var enemy = null;

@export var up_traj = Vector2.ZERO;
@export var left_traj = Vector2.ZERO;
@export var down_traj = Vector2.ZERO;
@export var right_traj = Vector2.ZERO;

var held_body;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if get_parent().id == 0: print(held_body)
	if held_body:
		held_body.position = global_position;
		held_body.sleeping = true;
		if held_body.get_linear_velocity() != Vector2.ZERO: held_body.set_linear_velocity(Vector2.ZERO)


func _on_body_entered(body):
	if body != get_parent(): enemy = body;


func _on_body_exited(body):
	if body != get_parent(): enemy = null;


func _on_grab_timer_timeout():
	held_body.is_grabbed = false;
	held_body = null;
	$Cooldown.start(.5);
	get_parent().grabbing = false;
