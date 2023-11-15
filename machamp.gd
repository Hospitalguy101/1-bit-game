extends Fighter


# Called when the node enters the scene tree for the first time.
func _ready():
	$BodyAnimation/BodyTree.active = true
	$SArmAnim/SArmTree.active = true
	$HArmAnim/HArmTree.active = true
	$GArmAnim/GArmTree.active = true
	$LArmAnim/LArmTree.active = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_animation_param()

func update_animation_param():
	if floored:
		$Sprite.position
