extends CharacterBody2D

func _ready():
	$Hurtbox.active = true;

func _physics_process(delta):
	move_and_slide()


func _on_duration_timeout():
	call_deferred("queue_free");


func _on_move_timer_timeout():
	velocity = Vector2.ZERO;
