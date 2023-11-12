extends Fighter

var ready_swords = 8;
@onready var swordPath = load("res://Characters/Rin/sword.tscn")

@onready var animation : AnimationTree = $AnimationTree

func _physics_process(delta):
	update_animation_param()
	super._physics_process(delta);
	

func light_attack(direction):
	#check is sword is availible
	if ready_swords > 0:
		#stick tilted left
		if direction.x < -1*Global.DEADZONE:
			#quick forwards attack
			var sword = swordPath.instantiate();
			sword.position.x = 20;
			sword.position.y = 0;
			sword.rotation = 0;
			$Swords.add_child(sword);
			
		#stick tilted up right
		elif direction.x > Global.DEADZONE and direction.y > Global.DEADZONE:
			pass
		
		#stick tilted down
		elif direction.y < -1*Global.DEADZONE:
			pass
			
		#default move
		else:
			pass

func update_animation_param():
	if floored:
		if self.linear_velocity.round() == Vector2.ZERO:
			animation["parameters/conditions/is_idle"] = true
			animation["parameters/conditions/is_walking"] = false
		else:
			animation["parameters/conditions/is_idle"] = false
			animation["parameters/conditions/is_walking"] = true
		if Input.is_action_just_pressed("grab"):
			animation["parameters/conditions/grab"] = true
		else:
			animation["parameters/conditions/grab"] = false
			
		if Input.is_action_pressed("crouch"):
			animation["parameters/conditions/is_crouching"] = true
			animation["parameters/conditions/is_not_crouching"] = false
		if Input.is_action_just_released("crouch"):
			animation["parameters/conditions/is_crouching"] = false
			animation["parameters/conditions/is_not_crouching"] = true
		if (Input.is_action_just_pressed("jump")):
			animation["parameters/conditions/jump"] = true
	else:
		if (Input.is_action_just_pressed("jump") and hasDoubleJump):
			animation["parameters/conditions/jump"] = true
		else:
			animation["parameters/conditions/jump"] = false
		
		
