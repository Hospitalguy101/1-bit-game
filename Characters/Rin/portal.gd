extends CharacterBody2D

@export var id = 0;
var isReady = true;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	move_and_slide();
	#set connectionbox to connect player to portal, always on ground
	if visible:
		$ConnectionBox/CollisionShape2D.shape.size.x = position.x;
		$ConnectionBox/CollisionShape2D.position.x = -position.x/2;


func break_portal():
	for p in get_parent().get_children():
		if p == self: continue;
		if p.isReady:
			get_parent().get_parent().currPortal = p;
			p.show();
			break;
			queue_free();

func use_portal():
	hide();
	isReady = false;
	$Cooldown.start(30);
	for p in get_parent().get_children():
		if p.isReady:
			get_parent().get_parent().currPortal = p;
			p.show();
			break;


func _on_cooldown_timeout():
	isReady = true;


func _on_connection_box_area_entered(area):
	if area.is_in_group("hurtbox"):
		#check that it is an enemy attack
		if area.id != get_parent().get_parent().id:
			break_portal();
