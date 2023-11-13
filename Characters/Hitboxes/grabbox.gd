extends Area2D

var enemy = null;
var active = false;

@export var command_grab = false;

@export var up_traj = Vector2.ZERO;
@export var left_traj = Vector2.ZERO;
@export var down_traj = Vector2.ZERO;
@export var right_traj = Vector2.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		if command_grab: enemy.position = get_node("/root/Game/GrabPointNode").position + Vector2(0, -10);
		else: enemy.position = get_node("/root/Game/GrabPointNode").position;
		enemy.sleeping = true;
		if enemy.get_linear_velocity() != Vector2.ZERO: enemy.set_linear_velocity(Vector2.ZERO)


func grab():
	print("grabx")
	if enemy and $Cooldown.is_stopped():
		active = true;
		#if command grab, only use the current portal
		if command_grab and get_parent().get_parent().get_parent().currPortal != get_parent():
			return;
		#create a node2d at the grab point to prevent both players from flying off screen
		if !get_node_or_null("/root/Game/GrabPointNode"):
			var node = Node2D.new();
			node.name = "GrabPointNode";
			node.position = global_position;
			get_node("/root/Game").add_child(node);
		
		if command_grab: get_parent().top_level = true;
		
		enemy.is_grabbed = true;
		$GrabTimer.start(1);
		
#0 = up, 1 = left, 2 = right, 3 = down
func throw(direction):
	$GrabTimer.stop();
	enemy.is_grabbed = false;
	$Cooldown.start(.5);
	match direction:
		0: enemy.set_axis_velocity(up_traj);
		1: enemy.set_axis_velocity(left_traj);
		2: enemy.set_axis_velocity(down_traj);
		3: enemy.set_axis_velocity(right_traj);
	active = false;
	get_node("/root/Game/GrabPointNode").queue_free();


func _on_body_entered(body):
	if body != get_parent(): enemy = body;


func _on_body_exited(body):
	if body != get_parent() and !active: enemy = null;


func _on_grab_timer_timeout():
	enemy.is_grabbed = false;
	active = false;
	$Cooldown.start(.5);
	get_node("/root/Game/GrabPointNode").queue_free();
	if command_grab:
		get_parent().get_parent().get_parent().grabbing = false;
	else:
		get_parent().grabbing = false;
