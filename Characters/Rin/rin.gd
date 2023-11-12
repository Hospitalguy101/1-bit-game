extends Fighter

var ready_swords = 8;
var sword_timer = 8;
@onready var swordPath = load("res://Characters/Rin/sword.tscn")

@onready var currPortal = $Portals/Portal;

@onready var animation : AnimationTree = $AnimationTree

func _ready():
	super._ready();
	for t in $SwordTimers.get_children():
		t.connect("timeout", _on_sword_timer_timeout);

func _physics_process(delta):
	update_animation_param()
	super._physics_process(delta);
	
	#temporary:
	$Label.text = str(ready_swords);
	#print(currPortal)
	

func light_attack(direction):
	#check is sword is availible
	if ready_swords > 0:
		#stick tilted left
		if direction.x < -Global.DEADZONE:
			#back light
			var sword = swordPath.instantiate();
			sword.position = Vector2.ZERO;
			sword.scale = Vector2(.2, .2);
			sword.velocity.x = 150;
			$Swords.add_child(sword);
			sword.initialize(0.1, Vector2(40, -80));
			
		#stick tilted up right
		elif direction.x > Global.DEADZONE and direction.y > Global.DEADZONE:
			var sword = swordPath.instantiate();
			sword.position = Vector2(5, -5);
			sword.scale = Vector2(.5, .2);
			sword.velocity = Vector2(150, -150);
			sword.rotate(-PI/4);
			$Swords.add_child(sword);
			sword.initialize(0.2, Vector2(35, -100), 1);
			use_sword(1);
		
		#stick tilted down
		elif direction.y < -Global.DEADZONE:
			var sword = swordPath.instantiate();
			sword.position = Vector2(3, 7);
			sword.scale = Vector2(.5, .2);
			sword.velocity.x = 150;
			$Swords.add_child(sword);
			sword.initialize(0.1, Vector2(80, -120), -1);
			use_sword(1);
			
		#default move
		else:
			var sword = swordPath.instantiate();
			sword.position = Vector2(3, 0);
			sword.scale = Vector2(.5, .2);
			sword.velocity.x = 150;
			$Swords.add_child(sword);
			sword.initialize(0.1, Vector2(60, -150));
			use_sword(1);


func slash_attack(direction):
	#stick down
	if direction.y < -Global.DEADZONE:
		pass
	
	if ready_swords >= 3:
		#stick right
		if direction.x > Global.DEADZONE:
			var sword = swordPath.instantiate();
			sword.position = currPortal.position;
			sword.scale = Vector2(.35, .2);
			sword.velocity = Vector2(1, -1) * 150;
			sword.rotate(-PI/4)
			$Swords.add_child(sword);
			sword.initialize(0.1, Vector2(150, -120), -1);
			use_sword(3);
			currPortal.use_portal();
		
		#stick left
		elif direction.x < -Global.DEADZONE:
			var sword = swordPath.instantiate();
			sword.position = currPortal.position;
			sword.scale = Vector2(.35, .2);
			sword.velocity = Vector2(-1, -1) * 150;
			sword.rotate(-PI*3/4)
			$Swords.add_child(sword);
			sword.initialize(0.1, Vector2(-150, -120), -1);
			use_sword(3);
			currPortal.use_portal();
			
		#stick up
		elif direction.y > Global.DEADZONE:
			var sword = swordPath.instantiate();
			sword.position = currPortal.position;
			sword.scale = Vector2(.35, .2);
			sword.velocity.y = -150;
			sword.rotate(-PI/2)
			$Swords.add_child(sword);
			sword.initialize(0.1, Vector2(0, -200), -1);
			use_sword(3);
			currPortal.use_portal();
	
	#no direction
	if direction.x < Global.DEADZONE and direction.x > -Global.DEADZONE and direction.y < Global.DEADZONE and direction.y > -Global.DEADZONE:
		print(currPortal)
		currPortal.velocity.x = 100;

func release_slash_attack():
	currPortal.velocity.x = 0;

func use_sword(cost):
	ready_swords -= cost;
	var timer_count = 0;
	for t in $SwordTimers.get_children():
		if t.is_stopped():
			t.start(sword_timer);
			timer_count += 1;
			if timer_count == cost: break

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

func _on_sword_timer_timeout():
	ready_swords += 1;
