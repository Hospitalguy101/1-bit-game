extends Fighter


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if crouching:
		$GPUParticles2D.set_position_(2,-7)
	else:
		$GPUParticles2D.set_position_(1,-11)
	update_animation_param()

func update_animation_param():
	if floored:
		$Sprite.position
