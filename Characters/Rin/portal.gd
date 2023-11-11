extends StaticBody2D

@export var id = 0;
var isReady = true;
var active = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if active: $Sprite2D.show();
	else: $Sprite2D.hide();


func start_cooldown():
	isReady = false;
	$Cooldown.start(30);


func _on_cooldown_timeout():
	isReady = true;
