extends Area2D

var enemy;
var active = false;

@export var blow_left = true;

# Called when the node enters the scene tree for the first time.
func _ready():
	top_level = true;
	position += get_parent().position;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if enemy and active: 
		if blow_left: enemy.apply_force(Vector2(-1000, 0));
		else: enemy.apply_force(Vector2(1000, 0));


func _on_body_entered(body):
	if body.is_in_group("Fighter") and body.id != get_parent().id: enemy = body;


func _on_body_exited(body):
	if body.is_in_group("Fighter") and body.id != get_parent().id: enemy = null;
