extends Area2D

var id = 0;

@export var launch_trajectory = Vector2.ZERO;
@export var break_on_hit = false;

#attack heights: 1 = high, 0 = medium, -1 = low
@export var attack_height = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func activate(time=null):
	$CollisionShape2D.disabled = false;
	if time: $Timer.start(time);

func deactivate():
	$CollisionShape2D.disabled = true;

func _on_body_entered(body):
	if body.is_in_group("Fighter") and body.id != id:
		body.set_axis_velocity(launch_trajectory);
		if break_on_hit: get_parent().queue_free();


func _on_timer_timeout():
	deactivate();
