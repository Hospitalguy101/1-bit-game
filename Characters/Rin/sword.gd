extends StaticBody2D

@export var id = 0;
var isReady = true;
var attacking = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	if attacking: $Area2D/CollisionShape2D.disabled = false;
	else: $Area2D/CollisionShape2D.disabled = true;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func start_cooldown():
	isReady = false;
	$Cooldown.start(30);


func _on_cooldown_timeout():
	isReady = true;
