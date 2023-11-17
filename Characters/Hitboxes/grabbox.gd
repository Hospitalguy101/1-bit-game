extends Area2D

var enemy = null;
var active = false;

@export var command_grab = false;

@export var has_up = true;
@export var up_traj = Vector2.ZERO;
@export var has_left = true;
@export var left_traj = Vector2.ZERO;
@export var has_down = true;
@export var down_traj = Vector2.ZERO;
@export var has_right = true;
@export var right_traj = Vector2.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active:
		Global.Grabbed = true
		if command_grab and enemy: enemy.position = get_node("/root/FightingGame/Game/GrabPointNode").position + Vector2(0, -15);
		elif enemy: enemy.position = get_node("/root/FightingGame/Game/GrabPointNode").position;
		enemy.sleeping = true;
		if enemy.get_linear_velocity() != Vector2.ZERO: enemy.set_linear_velocity(Vector2.ZERO)
	else:
		Global.Grabbed = false
		Global.Grab = false


func grab():
	if enemy and $Cooldown.is_stopped():
		Global.Grab = true
		#if command grab, only use the current portal
		if command_grab and get_parent().get_parent().get_parent().currPortal != get_parent():
			return;
			
		if !command_grab: get_parent().grabbing = true;
		
		enemy.is_grabbed = true;
			
		$ClashTimer.start(.167);
		


#0 = up, 1 = left, 2 = right
func throw(direction):
	if direction == 0 and !has_up: return false;
	if direction == 1 and !has_left: return false;
	if direction == 2 and !has_right: return false;
	
	if $DeferTimer.is_stopped():
		$GrabTimer.stop();
		enemy.is_grabbed = false;
		enemy.knocked_down = true;
		$Cooldown.start(.5);
		match direction:
			0: enemy.set_axis_velocity(up_traj);
			1: enemy.set_axis_velocity(left_traj);
			2: enemy.set_axis_velocity(right_traj);
		active = false;
		get_node("/root/FightingGame/Game/GrabPointNode").call_deferred("queue_free");
		return true;
	return false;
	

func down_throw(point:Vector2):
	if has_down and $DeferTimer.is_stopped():
		active = false;
		enemy.position = Vector2(-100, -100)
		Global.throwingDown = true
		$GrabTimer.stop();
		enemy.is_grabbed = false;
		$Cooldown.start(.5);
		enemy.position = point;
		enemy.set_axis_velocity(down_traj);
		get_node("/root/FightingGame/Game/GrabPointNode").call_deferred("queue_free");
		return true;
	return false;

func _on_body_entered(body):
	if body != get_parent(): enemy = body;

func _on_body_exited(body):
	if body != get_parent() and !active: enemy = null;


func _on_grab_timer_timeout():
	enemy.is_grabbed = false;
	active = false;
	$Cooldown.start(.5);
	if get_node_or_null("/root/FightingGame/Game/GrabPointNode"): get_node("/root/FightingGame/Game/GrabPointNode").call_deferred("queue_free");
	if command_grab:
		get_parent().get_parent().get_parent().grabbing = false;
	else:
		get_parent().grabbing = false;


func _on_clash_timer_timeout():
	#create a node2d at the grab point to prevent both players from flying off screen
		if !get_node_or_null("/root/FightingGame/Game/GrabPointNode"):
			var node = Node2D.new();
			node.name = "GrabPointNode";
			node.position = global_position;
			get_node("/root/FightingGame/Game").call_deferred("add_child", node);
		active = true;
		$GrabTimer.start(1);
		$DeferTimer.start(.01);
