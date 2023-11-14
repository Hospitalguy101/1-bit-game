extends Area2D

var id = 0;

var active = false;
var enemy;

@export var launch_trajectory = Vector2.ZERO;
@export var break_on_hit = false;
@export var disable_on_hit = false;

#attack heights: 1 = high, 0 = medium, -1 = low
@export var height = 0;

#will launch body to specific point instead of by force
@export var point_mode = false;
var launch_point = Vector2.ZERO;
var target;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target: target.position = launch_point;
	
	if active and enemy:
		if disable_on_hit: active = false;#$CollisionShape2D.disabled = true;
		if point_mode:
			enemy.sleeping = true;
			target = enemy;
		else:
			enemy.set_axis_velocity(launch_trajectory);
		if break_on_hit: get_parent().queue_free();
	
func activate(time=null):
	#$CollisionShape2D.disabled = false;
	active = true;
	if time: $Duration.start(time);
	
	
	#check if anyone is already inside the box
#	for p in get_node("/root/Game/Players").get_children():
#		if p.id != id and $CollisionShape2D.shape:
#			if p.position.x + p.get_node("BodyHitbox").shape.size.x/2 > global_position.x - $CollisionShape2D.shape.size.x/2:
#				if p.position.x - p.get_node("BodyHitbox").shape.size.x/2 < global_position.x + $CollisionShape2D.shape.size.x/2:
#					if p.position.y + p.get_node("BodyHitbox").shape.size.y/2 > global_position.y - $CollisionShape2D.shape.size.y/2:
#						if p.position.y - p.get_node("BodyHitbox").shape.size.x/2< global_position.y + $CollisionShape2D.shape.size.y/2:
#							_on_body_entered(p);

func deactivate():
	active = false;
	#$CollisionShape2D.disabled = true;
	target = null;

func _on_body_entered(body):
	print(body.is_in_group("Fighter"))
	if body.is_in_group("Fighter") and body.id != id:
		print("ENTER")
		enemy = body;

func _on_body_exited(body):
	if body.is_in_group("Fighter") and body.id != id:
		enemy = null;

func _on_duration_timeout():
	deactivate();
