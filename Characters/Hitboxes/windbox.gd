extends Area2D

var enemy;
var active = false;

@export var blow_left = true;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if enemy and active: 
		if blow_left: enemy.apply_force(Vector2(-1000, 0));
		else: enemy.apply_force(Vector2(1000, 0));


func activate(time=null):
	active = true;
	
	if get_parent().get_parent().on_left:
		blow_left = true;
		position += get_parent().get_parent().position;
	else:
		blow_left = false;
		position.x = get_parent().get_parent().position.x - position.x;
		position.y += get_parent().get_parent().position.y;
	
	top_level = true;
	
	
	if time: $Duration.start(time);
	

func deactivate():
	active = false;
	top_level = false;
	position = Vector2(55, -5.5);

func _on_body_entered(body):
	if body.is_in_group("Fighter") and body.id != get_parent().get_parent().id: enemy = body;


func _on_body_exited(body):
	if body.is_in_group("Fighter") and body.id != get_parent().get_parent().id: enemy = null;


func _on_duration_timeout():
	deactivate();
