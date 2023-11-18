extends Fighter

var ready_swords = 8;
var sword_timer = 8;
@onready var swordPath = load("res://Characters/Rin/sword.tscn")

@onready var currPortal = $Portals/Portal;

var special_portal;

#0 = default, 1 = up right, 2 = down, 3 = down right
var last_heavy_attack = 0;

@onready var animation : AnimationTree = $AnimationTree

func _ready():
	super._ready();
	down_throw_point = Vector2(1500, -15);
	for t in $SwordTimers.get_children():
		t.connect("timeout", _on_sword_timer_timeout);

func _physics_process(delta):
	update_animation_param()
	super._physics_process(delta);
	
	#temporary:
	$Label.text = "S: " + str(ready_swords);
	var ready_portals = 0;
	for p in $Portals.get_children():
		if p.isReady: ready_portals += 1;
	$Label2.text = "P: " + str(ready_portals)
	

func light_attack(direction):
	#check is sword is availible
	if ready_swords > 0:
		#stick tilted left
		if direction.x < -Global.DEADZONE:
			#back light
			var sword = create_sword(Vector2(-5, 0), Vector2(.2, .2), Vector2(150, 0), 0);
			sword.initialize(0.1, Vector2(40, -80));
			
		#stick tilted up right
		elif direction.x > Global.DEADZONE and direction.y > Global.DEADZONE:
			var sword = create_sword(Vector2(0, -5), Vector2(.5, .2), Vector2(150, -150), -PI/4);
			sword.initialize(0.2, Vector2(35, -100), 1);
			use_sword(1);
		
		#stick tilted down
		elif direction.y < -Global.DEADZONE:
			var sword = create_sword(Vector2(-2, 8), Vector2(.5, .2), Vector2(150, 0), 0);
			sword.initialize(0.1, Vector2(80, -120), -1);
			sword.get_node("Hurtbox").knockdown = true;
			use_sword(1);
			
		#default move
		else:
			var sword = create_sword(Vector2(-2, 0), Vector2(.5, .2), Vector2(150, 0), 0);
			sword.initialize(0.1, Vector2(60, -150));
			use_sword(1);

func slash_attack(direction):
	#stick down
	if direction.y < -Global.DEADZONE and abs(direction.x) < Global.DEADZONE and currPortal and !grabbing:
		currPortal.get_node("Grabbox").grab();
		currPortal.use_portal();
	
	elif ready_swords >= 3 and currPortal:
		#stick right
		if direction.x > Global.DEADZONE:
			var sword = create_sword(Vector2(-5, 5), Vector2(.35, .2), Vector2(1, -1).normalized()*150, PI/4, true, currPortal.position);
			if on_left:
				sword.rotation = -PI/4;
				sword.velocity = Vector2(1, -1).normalized()*150;
			else:
				sword.rotation = PI/4;
				sword.velocity = Vector2(-1, -1).normalized()*150;
			sword.initialize(0.1, Vector2(150, -120), -1);
			sword.get_node("Hurtbox").knockdown = true;
			use_sword(3);
			currPortal.use_portal();
		
		#stick left
		elif direction.x < -Global.DEADZONE:
			var sword = create_sword(Vector2(5, 5), Vector2(.35, .2), Vector2(-1, -1).normalized()*150, -PI/4, true, currPortal.position);
			if on_left:
				sword.rotation = -PI*3/4;
				sword.velocity = Vector2(-1, -1).normalized()*150;
			else:
				sword.rotation = PI*3/4;
				sword.velocity = Vector2(1, -1).normalized()*150;
			sword.initialize(0.1, Vector2(-150, -120), -1);
			sword.get_node("Hurtbox").knockdown = true;
			use_sword(3);
			currPortal.use_portal();
			
		#stick up
		elif direction.y > Global.DEADZONE:
			var sword = create_sword(Vector2(0, 5), Vector2(.35, .2), Vector2(0, -150), -PI/2, true, currPortal.position);
			sword.initialize(0.1, Vector2(0, -200), -1);
			sword.get_node("Hurtbox").knockdown = true;
			use_sword(3);
			currPortal.use_portal();
	
	#no direction
	if currPortal and direction.x < Global.DEADZONE and direction.x > -Global.DEADZONE and direction.y < Global.DEADZONE and direction.y > -Global.DEADZONE:
		$AttackTimers/PortalRecallTimer.start(0.1);

func release_slash_attack():
	if $AttackTimers/PortalRecallTimer.is_stopped() and currPortal: currPortal.velocity.x = 0;
	elif currPortal:
		currPortal.position = position + Vector2(0, 13);
		$AttackTimers/PortalRecallTimer.stop();
		currPortal.velocity.x = 0;


func heavy_attack(direction):
	#get a ready portal, if there are none, use the active one
	var portal;
	for p in $Portals.get_children():
		if p.isReady and !p.visible:
			portal = p;
			break;
	if !portal: portal = currPortal;
		
	if ready_swords >= 2 and portal and $AttackTimers/HeavyTimer.is_stopped():
		portal.using_heavy = true;
		portal.ground = false;
		#down right
		if direction.x > Global.DEADZONE and direction.y < -Global.DEADZONE:
			var sword = create_sword(Vector2(5, -10), Vector2(.5, .2), Vector2(1, .5).normalized()*80, PI/6, true, position);
			if on_left:
				sword.rotation = PI/6;
				sword.velocity.x *= -1;
			else: sword.rotation = -PI/6;
			sword.get_node("Hurtbox").set_collision_mask_value(2, true)
			sword.initialize(3, Vector2(100, -100));
			sword.add_to_group("HeavySwords");
			sword.get_node("Hurtbox").break_on_hit = false;
			
			portal.position = position + Vector2(10, -6)
			if on_left: portal.rotation = 3*PI/4;
			else: portal.rotation = -3*PI/4;
			portal.show();
			portal.get_node("ConnectionBox/CollisionShape2D").set_deferred("disabled", true);
			
			last_heavy_attack = 3;
			$AttackTimers/HeavyTimer.start(3);
			use_sword(2);
			
		#down
		elif direction.y < -Global.DEADZONE:
			#create 3 swords, add to group heavy sword, and dont have them break on hit
			var smallSword = create_sword(Vector2(12, -30), Vector2(.35, .2), Vector2.ZERO, PI/2, true, position);
			smallSword.initialize(0.15, Vector2(0, 200), 0, false);
			smallSword.add_to_group("HeavySwords");
			var hurtbox = smallSword.get_node("Hurtbox");
			hurtbox.break_on_hit = false;
			
			var smallSword1 = create_sword(Vector2(18, -30), Vector2(.35, .2), Vector2.ZERO, PI/2, true, position);
			smallSword1.initialize(0.15, Vector2(0, 200), 0, false);
			smallSword1.add_to_group("HeavySwords");
			hurtbox = smallSword1.get_node("Hurtbox");
			hurtbox.break_on_hit = false;
			
			var bigSword = create_sword(Vector2(15, -30), Vector2(.5, .2), Vector2.ZERO, PI/2, true, position);
			bigSword.initialize(0.15, Vector2(0, 200), 0, false);
			bigSword.add_to_group("HeavySwords");
			bigSword.get_node("Hurtbox").break_on_hit = false;
			hurtbox = bigSword.get_node("Hurtbox");
			hurtbox.break_on_hit = false;
			
			if !on_left:
				smallSword.rotate(PI);
				smallSword1.rotate(PI);
				bigSword.rotate(PI);
		
			portal.position = position + Vector2(15, -30);
			portal.position.x = bigSword.position.x
			if on_left: portal.rotation = PI;
			else: portal.rotation = -PI;
			portal.show();
			portal.get_node("ConnectionBox/CollisionShape2D").set_deferred("disabled", true);
			
			last_heavy_attack = 2;
			$AttackTimers/HeavyTimer.start(.8);
			
			use_sword(2);
			
		#up right
		elif direction.x > Global.DEADZONE and direction.y > Global.DEADZONE:
			#create 3 swords, add to group heavy sword, and dont have them break on hit
			#using rotate_point to keep the swords in proper formation while having different rotation
			var smallSword = create_sword(rotate_point(Vector2(4, 5), -PI/4), Vector2(.35, .2), Vector2.ZERO, -PI/4, true, position);
			smallSword.initialize(0.15, Vector2(150, -200), 0, false);
			smallSword.add_to_group("HeavySwords");
			smallSword.get_node("Hurtbox").break_on_hit = false;
			var smallSword1 = create_sword(rotate_point(Vector2(4, -5), -PI/4), Vector2(.35, .2), Vector2.ZERO, -PI/4, true, position);
			smallSword1.initialize(0.15, Vector2(150, -200), 0, false);
			smallSword1.add_to_group("HeavySwords");
			smallSword1.get_node("Hurtbox").break_on_hit = false;
			var bigSword = create_sword(rotate_point(Vector2(4, 0), -PI/4), Vector2(.5, .2), Vector2.ZERO, -PI/4, true, position);
			bigSword.initialize(0.15, Vector2(150, -200), 0, false);
			bigSword.add_to_group("HeavySwords");
			bigSword.get_node("Hurtbox").break_on_hit = false;
		
			portal.position = position + Vector2(-2, 0);
			if on_left: portal.rotation = PI/4;
			else: portal.rotation = -PI/4;
			portal.show();
			portal.get_node("ConnectionBox/CollisionShape2D").set_deferred("disabled", true);
			
			last_heavy_attack = 1;
			$AttackTimers/HeavyTimer.start(.8);
			
			use_sword(2);
			
		else:
			#create 3 swords, add to group heavy sword, and dont have them break on hit
			var smallSword = create_sword(Vector2(5, 5), Vector2(.35, .2), Vector2.ZERO, 0, true, position);
			smallSword.initialize(0.15, Vector2(150, -200), 0, false);
			smallSword.add_to_group("HeavySwords");
			smallSword.get_node("Hurtbox").break_on_hit = false;
			var smallSword1 = create_sword(Vector2(5, -5), Vector2(.35, .2), Vector2.ZERO, 0, true, position);
			smallSword1.initialize(0.15, Vector2(150, -200), 0, false);
			smallSword1.add_to_group("HeavySwords");
			smallSword1.get_node("Hurtbox").break_on_hit = false;
			var bigSword = create_sword(Vector2(5, 0), Vector2(.5, .2), Vector2.ZERO, 0, true, position);
			bigSword.initialize(0.15, Vector2(150, -200), 0, false);
			bigSword.add_to_group("HeavySwords");
			bigSword.get_node("Hurtbox").break_on_hit = false;
		
			portal.position = position + Vector2(-2, 0);
			if on_left: portal.rotation = PI/2;
			else: portal.rotation = -PI/2;
			portal.show();
			portal.get_node("ConnectionBox/CollisionShape2D").set_deferred("disabled", true);
			
			last_heavy_attack = 0;
			$AttackTimers/HeavyTimer.start(.8);
			
			use_sword(2);


#mode 1 = light, 2 = heavy
func special1(mode):
	if floored and (ready_swords > 3 or (ready_swords > 2 and mode == 1)):
		special_step = 0;
		
		var portal;
		if currPortal: 
			portal = currPortal;
		for p in $Portals.get_children():
			if p != currPortal:
				portal = p;
		for p in $Portals.get_children():
			if p.visible == false:
				portal = p;
		if portal == currPortal:
			currPortal = null;
		special_portal = portal;
		
		var enemy;
		for p in Global.players:
			if p.id != id:
				enemy = p;
		var sword = create_sword(Vector2(30, 0), Vector2(.2, .2), Vector2(-150, 0), PI, true, enemy.position);
		sword.initialize(0.1, Vector2(-100, -80));
		if mode == 1: use_sword(3);
		else:
			sword.scale = Vector2(.3, .5);
			sword.get_node("Hurtbox").launch_trajectory = Vector2(-200, -150);
			use_sword(4);
			if !on_left: sword.rotate(PI);
		if on_left: sword.velocity.x *= -1;
		
		portal.position = sword.position + Vector2(2, 0);
		if on_left: portal.rotation = PI/2;
		else: portal.rotation = -PI/2;
		portal.ground = false;
		portal.show();
		portal.get_node("ConnectionBox/CollisionShape2D").set_deferred("disabled", true);
		$AttackTimers/Special1PortalTimer.start(0.2);
		

func special2():
	special_step = 0;
	#find a portal to delete
	var portal_to_delete;
	if currPortal: 
		portal_to_delete = currPortal;
	for p in $Portals.get_children():
		if p != currPortal:
			portal_to_delete = p;
	for p in $Portals.get_children():
		if p.visible == false:
			portal_to_delete = p;
	if portal_to_delete == currPortal:
		currPortal = null;
	portal_to_delete.call_deferred("queue_free");
	
	for t in $SwordTimers.get_children():
		t.stop();
	ready_swords = 8;
	

func special3():
	if floored:
		special_step = 0;
		
		#find a portal to delete
		var portal_to_delete;
		if currPortal: 
			portal_to_delete = currPortal;
		for p in $Portals.get_children():
			if p != currPortal:
				portal_to_delete = p;
		for p in $Portals.get_children():
			if p.visible == false:
				portal_to_delete = p;
		if portal_to_delete == currPortal:
			currPortal = null;
		portal_to_delete.call_deferred("queue_free");
		
		var sword = create_sword(Vector2(19, 20), Vector2(.7, .7), Vector2.ZERO, -PI/2, true, position);
		sword.id = id;
		var hurtbox = sword.get_node("Hurtbox")
		hurtbox.knockdown = true;
		hurtbox.point_mode = true;
		hurtbox.launch_point = position + Vector2(15, -20);
		hurtbox.disable_on_hit = true;
		sword.initialize(1, Vector2.ZERO, -1);
		sword.add_to_group("SpecialSwords");
		$AttackTimers/Special3Timer.wait_time = 1;
		$AttackTimers/Special3Timer.autostart = true;


func _unhandled_input(event):
	if !motion_combo:
		#hard down, special 1 and 2
		if event is InputEventJoypadMotion and abs(direction.x) < Global.DEADZONE and direction.y < -Global.DEADZONE:
			special_step = 0;
			current_special = 1;
			motion_combo = true;
			progress_combo()
		#hard right, special 3
		elif event is InputEventJoypadMotion and direction.x > Global.DEADZONE and abs(direction.y) < Global.DEADZONE:
			special_step = 0;
			current_special = 3;
			motion_combo = true;
			progress_combo();
	else:
		match special_step:
			1:
				if current_special == 1:
					
					#down left, special 1
					if event is InputEventJoypadMotion and direction.x < -Global.DEADZONE and direction.y < -Global.DEADZONE:
						progress_combo();
					#down right, special 2
					elif event is InputEventJoypadMotion and direction.x > Global.DEADZONE and direction.y < -Global.DEADZONE:
						current_special = 2;
						progress_combo();
					#if a move is used or jump is pressed, break combo
					elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
						motion_combo = false;
						#super._unhandled_input(event);
						
				if current_special == 3:
					#down right
					if event is InputEventJoypadMotion and direction.x > Global.DEADZONE and direction.y < -Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
						motion_combo = false;
						#super._unhandled_input(event);
			2:
				if current_special == 1:
					#hard left
					if event is InputEventJoypadMotion and direction.x < -Global.DEADZONE and abs(direction.y) < Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
						motion_combo = false;
						#super._unhandled_input(event);
				
				if current_special == 2:
					#hard right
					if event is InputEventJoypadMotion and direction.x > Global.DEADZONE and abs(direction.y) < Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
						motion_combo = false;
						#super._unhandled_input(event);
				
				if current_special == 3:
					#hard down
					if event is InputEventJoypadMotion and abs(direction.x) < Global.DEADZONE and direction.y < -Global.DEADZONE:
						progress_combo()
					elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
						motion_combo = false;
						#super._unhandled_input(event);
			3:
				if current_special == 1:
					if Input.is_action_pressed("p1_light_attack"):
						special1(1);
					elif Input.is_action_pressed("p1_heavy_attack"):
						special1(2);
					elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
						motion_combo = false;
						#super._unhandled_input(event);
				
				if current_special == 2:
					#no direction
					if event is InputEventJoypadMotion and abs(direction.x) < Global.DEADZONE and abs(direction.y) < Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and abs(direction.x) < Global.DEADZONE and direction.y < -Global.DEADZONE):
						motion_combo = false;
						#super._unhandled_input(event);
				
				if current_special == 3:
					#down left
					if event is InputEventJoypadMotion and direction.x < -Global.DEADZONE and direction.y < -Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
						motion_combo = false;
						#super._unhandled_input(event);
			4:
				if current_special == 2:
					#hard right
					if event is InputEventJoypadMotion and direction.x > Global.DEADZONE and abs(direction.y) < Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
						motion_combo = false;
						#super._unhandled_input(event);
				
				if current_special == 3:
					#hard left
					if event is InputEventJoypadMotion and direction.x < -Global.DEADZONE and abs(direction.y) < Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
						motion_combo = false;
						#super._unhandled_input(event);
			5:
				if current_special == 2:
					if Input.is_action_pressed("p1_slash_attack"):
						special2();
					elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
						motion_combo = false;
						#super._unhandled_input(event);
				
				if current_special == 3:
					#up left
					if event is InputEventJoypadMotion and direction.x < -Global.DEADZONE and direction.y > Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
						#super._unhandled_input(event);
			6:
				#hard up
				if event is InputEventJoypadMotion and abs(direction.x) < Global.DEADZONE and direction.y > Global.DEADZONE:
					progress_combo()
				elif event is InputEventJoypadButton or event is InputEventKey:
					motion_combo = false;
					#super._unhandled_input(event);
			7:
				#up right
				if event is InputEventJoypadMotion and direction.x > Global.DEADZONE and direction.y > Global.DEADZONE:
					progress_combo();
				elif event is InputEventJoypadButton or event is InputEventKey:
					motion_combo = false;
					#super._unhandled_input(event);
			8:
				#hard right
				if event is InputEventJoypadMotion and direction.x > Global.DEADZONE and abs(direction.y) < Global.DEADZONE:
					progress_combo();
				elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
					motion_combo = false;
					#super._unhandled_input(event);
			9:
				if Input.is_action_pressed("p1_heavy_attack"):
					progress_combo();
				elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
					motion_combo = false;
					super._unhandled_input(event);
			10:
				if Input.is_action_pressed("p1_slash_attack", false) or Input.is_action_just_released("p1_slash_attack", false):
					special3();
				elif event is InputEventJoypadButton or event is InputEventKey:# or (event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE):
					motion_combo = false;
					#super._unhandled_input(event);
				
	super._unhandled_input(event);
	if special_step == 0: motion_combo = false;


func create_sword(_position, _scale, _speed, _rotation, absolute=false, ref_vec=null):
	var sword = swordPath.instantiate();
	sword.rotation = _rotation;
	sword.position = _position;
	sword.scale = _scale;
	sword.velocity = _speed;
	if !on_left and !absolute:
		sword.position.x *= -1;
		sword.velocity.x *= -1;
	sword.id = id;
	sword.get_node("Hurtbox").activate();
	if absolute: 
		if !on_left and ref_vec:
			sword.scale.x *= -1;
			sword.position.x = ref_vec.x - sword.position.x;
			sword.position.y += ref_vec.y;
			sword.velocity.x *= -1;
		elif ref_vec:
			sword.position += ref_vec;
			sword.velocity.x *= -1;
		sword.top_level = true;
	
	$Swords.call_deferred("add_child", sword);
	return sword;


func use_sword(cost):
	ready_swords -= cost;
	var timer_count = 0;
	for t in $SwordTimers.get_children():
		if t.is_stopped():
			t.start(sword_timer);
			timer_count += 1;
			if timer_count == cost: break


func rotate_point(point, angle):
	var newX = point.x*cos(angle) - point.y*sin(angle);
	var newY = point.y*cos(angle) + point.x*sin(angle);
	return Vector2(newX, newY);


func update_animation_param():
	if blocking or crouch_blocking:
		animation["parameters/conditions/Block"] = true
		animation["parameters/conditions/nBlock"] = false
	else:
		animation["parameters/conditions/Block"] = false
		animation["parameters/conditions/nBlock"] = true
	if hitstun:
		animation["parameters/conditions/hit"] = true
	if floored:
		animation["parameters/conditions/onGround"] = true
		if linear_velocity.round() == Vector2.ZERO:
			animation["parameters/conditions/is_idle"] = true
			animation["parameters/conditions/is_walking"] = false
		else:
			animation["parameters/conditions/is_idle"] = false
			animation["parameters/conditions/is_walking"] = true
		if Input.is_action_just_pressed("p1_grab"):
			animation["parameters/conditions/grab"] = true
		else:
			animation["parameters/conditions/grab"] = false
			
		if Input.is_action_pressed("p1_crouch"):
			animation["parameters/conditions/is_crouch"] = true
			animation["parameters/conditions/is_not_crouch"] = false
		if Input.is_action_just_released("p1_crouch"):
			animation["parameters/conditions/is_crouch"] = false
			animation["parameters/conditions/is_not_crouch"] = true
		if Input.is_action_just_pressed("p1_jump") and not is_grabbed and not grabbing:
			animation["parameters/conditions/jump"] = true
	else:
		animation["parameters/conditions/onGround"] = false
		if Input.is_action_just_pressed("p1_jump") and hasDoubleJump and not is_grabbed and not grabbing:
			animation["parameters/conditions/jump"] = true
		else:
			animation["parameters/conditions/jump"] = false

func _on_sword_timer_timeout():
	ready_swords += 1;


func _on_heavy_timer_timeout():
	#normal heavy
	if last_heavy_attack == 0:
		for s in $Swords.get_children():
			if s.is_in_group("HeavySwords"):
				s.get_node("AttackTimer").start(0.3);
				s.velocity.x = 150;
				if !on_left:
					s.velocity.x *= -1;
				
	#up right heavy
	if last_heavy_attack == 1:
		for s in $Swords.get_children():
			if s.is_in_group("HeavySwords"):
				s.get_node("AttackTimer").start(0.3);
				s.velocity = Vector2(1, -1).normalized()*150;
				if !on_left:
					s.velocity.x *= -1;
				
	#down heavy
	if last_heavy_attack == 2:
		for s in $Swords.get_children():
			if s.is_in_group("HeavySwords"):
				s.get_node("AttackTimer").start(0.3);
				s.velocity.y = 150;
				if !on_left:
					s.velocity.x *= -1;
				
	for p in $Portals.get_children():
		if p.using_heavy:
			p.using_heavy = false;
			p.use_portal();
			p.get_node("ConnectionBox/CollisionShape2D").set_deferred("disabled", true);


func _on_portal_recall_timer_timeout():
	if on_left: currPortal.velocity.x = 100;
	else: currPortal.velocity.x = -100;


func _on_special_3_timer_timeout():
	for s in $Swords.get_children():
		if s.is_in_group("SpecialSwords"):
			s.velocity = Vector2.ZERO;
			s.get_node("AttackTimer").start(1);


func _on_special_1_portal_timer_timeout():
	if special_portal:
		special_portal.use_portal();
		special_portal = null;


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "Hit": animation["parameters/conditions/hit"] = false;
