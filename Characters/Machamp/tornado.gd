extends CharacterBody2D

func _ready():
	var tween = get_tree().create_tween();
	tween.tween_property(self, "scale", Vector2(1, 1), 1.2);
	$Hurtbox.active = true;

func _physics_process(delta):
	move_and_slide()


func _on_duration_timeout():
	queue_free();
