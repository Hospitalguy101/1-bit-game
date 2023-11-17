extends Area2D

var id = 0;

var active = false;
var enemy;

@export var damage = 0;

@export var launch_trajectory = Vector2.ZERO;
@export var break_on_hit = false;
@export var disable_on_hit = false;

@export var knockdown = false;

#attack heights: 1 = high, 0 = medium, -1 = low
@export var height = 0;

#will launch body to specific point instead of by force
@export var point_mode = false;
var launch_point = Vector2.ZERO;
var target;

signal enemy_hit;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target: target.position = launch_point;
	
	if active and enemy:
		if enemy.blocking and (height == 1 or height == 0):
			enemy.blockstun = true;
			enemy.get_node("StunTimer").start(.15);
		elif enemy.crouch_blocking and (height == -1 or height == 0):
			enemy.blockstun = true;
			enemy.get_node("StunTimer").start(.05);
		else:
			enemy_hit.emit(enemy);
			if disable_on_hit: active = false;
			if point_mode:
				enemy.sleeping = true;
				target = enemy;
			else:
				var owner;
				for p in Global.players:
					if p.id == id:
						owner = p;
				if owner.on_left: enemy.set_axis_velocity(launch_trajectory);
				else: enemy.set_axis_velocity(Vector2(-launch_trajectory.x, launch_trajectory.y));
				enemy.hp -= damage * Global.color_modifier * owner.damage_modifier;
			if break_on_hit: get_parent().queue_free();
	
func activate(time=null):
	active = true;
	if time: $Duration.start(time);
	

func deactivate():
	active = false;
	#$CollisionShape2D.disabled = true;
	target = null;

func _on_body_entered(body):
	if body.is_in_group("Fighter") and body.id != id:
		enemy = body;

func _on_body_exited(body):
	if body.is_in_group("Fighter") and body.id != id:
		enemy = null;

func _on_duration_timeout():
	deactivate();
