extends StaticBody2D

@export var id = 0;
var isReady = true;

var trajectory

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func initialize(traj):
	trajectory = traj;

func start_cooldown():
	isReady = false;
	$Cooldown.start(30);


func _on_cooldown_timeout():
	isReady = true;
