extends Fighter

var ready_swords = 8;
var sword_timer = 8;
@onready var swordPath = load("res://Characters/Rin/sword.tscn")

@onready var currPortal = $Portals/Portal;

#0 = default, 1 = up right, 2 = down, 3 = down right
var last_heavy_attack = 0;

@onready var animation : AnimationTree = $AnimationTree

func _ready():
	super._ready();
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
			var sword = create_sword(Vector2(-2, 5), Vector2(.5, .2), Vector2(150, 0), 0);
			sword.initialize(0.1, Vector2(80, -120), -1);
			use_sword(1);
			
		#default move
		else:
			var sword = create_sword(Vector2(-2, 0), Vector2(.5, .2), Vector2(150, 0), 0);
			sword.initialize(0.1, Vector2(60, -150));
			use_sword(1);

func slash_attack(direction):
	#stick down
	if direction.y < -Global.DEADZONE and currPortal:
		print("B")
		currPortal.get_node("Grabbox").grab();
		currPortal.use_portal();
	
	elif ready_swords >= 3:
		#stick right
		if direction.x > Global.DEADZONE:
			var sword = create_sword(currPortal.position + Vector2(-5, 5), Vector2(.35, .2), Vector2(1, -1)*150, -PI/4);
			sword.initialize(0.1, Vector2(150, -120), -1);
			use_sword(3);
			currPortal.use_portal();
		
		#stick left
		elif direction.x < -Global.DEADZONE:
			var sword = create_sword(currPortal.position + Vector2(5, 5), Vector2(.35, .2), Vector2(-1, -1)*150, -PI*3/4);
			sword.initialize(0.1, Vector2(-150, -120), -1);
			use_sword(3);
			currPortal.use_portal();
			
		#stick up
		elif direction.y > Global.DEADZONE:
			var sword = create_sword(currPortal.position + Vector2(0, 5), Vector2(.35, .2), Vector2(0, -150), -PI/2);
			sword.initialize(0.1, Vector2(0, -200), -1);
			use_sword(3);
			currPortal.use_portal();
	
	#no direction
	if currPortal and direction.x < Global.DEADZONE and direction.x > -Global.DEADZONE and direction.y < Global.DEADZONE and direction.y > -Global.DEADZONE:
		$AttackTimers/PortalRecallTimer.start(0.1);

func release_slash_attack():
	if $AttackTimers/PortalRecallTimer.is_stopped() and currPortal: currPortal.velocity.x = 0;
	elif currPortal:
		currPortal.position = Vector2(0, 10);
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
		#down right
		if direction.x > Global.DEADZONE and direction.y < -Global.DEADZONE:
			var sword = create_sword(position + Vector2(5, -10), Vector2(.5, .2), Vector2(1, .5)*80, PI/6, true);
			sword.get_node("Hurtbox").set_collision_mask_value(2, true)
			sword.initialize(3, Vector2(100, -100));
			sword.add_to_group("HeavySwords");
			sword.get_node("Hurtbox").break_on_hit = false;
			
			portal.position = position + Vector2(10, -6)
			portal.top_level = true;
			portal.show();
			portal.get_node("ConnectionBox/CollisionShape2D").disabled = true;
			
			last_heavy_attack = 3;
			$AttackTimers/HeavyTimer.start(3);
			use_sword(2);
			
		#down
		elif direction.y < -Global.DEADZONE:
			#create 3 swords, add to group heavy sword, and dont have them break on hit
			var smallSword = create_sword(position + Vector2(12, -30), Vector2(.35, .2), Vector2.ZERO, PI/2, true);
			smallSword.initialize(0.15, Vector2(0, 200), 0, false);
			smallSword.add_to_group("HeavySwords");
			smallSword.get_node("Hurtbox").break_on_hit = false;
			var smallSword1 = create_sword(position + Vector2(18, -30), Vector2(.35, .2), Vector2.ZERO, PI/2, true);
			smallSword1.initialize(0.15, Vector2(0, 200), 0, false);
			smallSword1.add_to_group("HeavySwords");
			smallSword1.get_node("Hurtbox").break_on_hit = false;
			var bigSword = create_sword(position + Vector2(15, -30), Vector2(.5, .2), Vector2.ZERO, PI/2, true);
			bigSword.initialize(0.15, Vector2(0, 200), 0, false);
			bigSword.add_to_group("HeavySwords");
			bigSword.get_node("Hurtbox").break_on_hit = false;
		
			portal.position = position + Vector2(15, -30);
			portal.show();
			#makes portal movement not based on player movement
			portal.top_level = true;
			portal.get_node("ConnectionBox/CollisionShape2D").disabled = true;
			
			last_heavy_attack = 2;
			$AttackTimers/HeavyTimer.start(.8);
			
			use_sword(2);
			
		#up right
		elif direction.x > Global.DEADZONE and direction.y > Global.DEADZONE:
			#create 3 swords, add to group heavy sword, and dont have them break on hit
			#using rotate_point to keep the swords in proper formation while having different rotation
			var smallSword = create_sword(position + rotate_point(Vector2(4, 5), -PI/4), Vector2(.35, .2), Vector2.ZERO, -PI/4, true);
			smallSword.initialize(0.15, Vector2(150, -200), 0, false);
			smallSword.add_to_group("HeavySwords");
			smallSword.get_node("Hurtbox").break_on_hit = false;
			var smallSword1 = create_sword(position + rotate_point(Vector2(4, -5), -PI/4), Vector2(.35, .2), Vector2.ZERO, -PI/4, true);
			smallSword1.initialize(0.15, Vector2(150, -200), 0, false);
			smallSword1.add_to_group("HeavySwords");
			smallSword1.get_node("Hurtbox").break_on_hit = false;
			var bigSword = create_sword(position + rotate_point(Vector2(4, 0), -PI/4), Vector2(.5, .2), Vector2.ZERO, -PI/4, true);
			bigSword.initialize(0.15, Vector2(150, -200), 0, false);
			bigSword.add_to_group("HeavySwords");
			bigSword.get_node("Hurtbox").break_on_hit = false;
		
			portal.position = position + Vector2(-2, 0);
			portal.rotation = -PI/4;
			portal.show();
			#makes portal movement not based on player movement
			portal.top_level = true;
			portal.get_node("ConnectionBox/CollisionShape2D").disabled = true;
			
			last_heavy_attack = 1;
			$AttackTimers/HeavyTimer.start(.8);
			
			use_sword(2);
			
		else:
			#create 3 swords, add to group heavy sword, and dont have them break on hit
			var smallSword = create_sword(position + Vector2(5, 5), Vector2(.35, .2), Vector2.ZERO, 0, true);
			smallSword.initialize(0.15, Vector2(150, -200), 0, false);
			smallSword.add_to_group("HeavySwords");
			smallSword.get_node("Hurtbox").break_on_hit = false;
			var smallSword1 = create_sword(position + Vector2(5, -5), Vector2(.35, .2), Vector2.ZERO, 0, true);
			smallSword1.initialize(0.15, Vector2(150, -200), 0, false);
			smallSword1.add_to_group("HeavySwords");
			smallSword1.get_node("Hurtbox").break_on_hit = false;
			var bigSword = create_sword(position + Vector2(5, 0), Vector2(.5, .2), Vector2.ZERO, 0, true);
			bigSword.initialize(0.15, Vector2(150, -200), 0, false);
			bigSword.add_to_group("HeavySwords");
			bigSword.get_node("Hurtbox").break_on_hit = false;
		
			portal.position = position + Vector2(-2, 0);
			portal.show();
			#makes portal movement not based on player movement
			portal.top_level = true;
			portal.get_node("ConnectionBox/CollisionShape2D").disabled = true;
			
			last_heavy_attack = 0;
			$AttackTimers/HeavyTimer.start(.8);
			
			use_sword(2);


#mode 1 = light, 2 = heavy
func special1(mode):
	motion_combo = false;

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
	portal_to_delete.queue_free();
	for t in $SwordTimers.get_children():
		t.stop();
	ready_swords = 8;


func _unhandled_input(event):
	if !motion_combo:
		#hard down, special 1 and 2
		if event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE:
			special_step = 0;
			current_special = 1;
			motion_combo = true;
			progress_combo()
		#hard right, wspecial 3
		elif event is InputEventJoypadMotion and direction.x > Global.DEADZONE and direction.y > -Global.DEADZONE and direction.y < Global.DEADZONE:
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
					elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
						print("end")
						super._unhandled_input(event);
						
				if current_special == 3:
					#down right
					if event is InputEventJoypadMotion and direction.x > Global.DEADZONE and direction.y < -Global.DEADZONE:
						current_special = 2;
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
						super._unhandled_input(event);
			2:
				if current_special == 1:
					#hard left
					if event is InputEventJoypadMotion and direction.x < -Global.DEADZONE and direction.y > -Global.DEADZONE and direction.y < Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
						super._unhandled_input(event);
				
				if current_special == 2:
					#hard right
					if event is InputEventJoypadMotion and direction.x > Global.DEADZONE and direction.y > -Global.DEADZONE and direction.y < Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
						super._unhandled_input(event);
				
				if current_special == 3:
					#hard down
					if event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < -Global.DEADZONE:
						progress_combo()
					elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
						super._unhandled_input(event);
			3:
				if current_special == 1:
					if Input.is_action_pressed("light_attack"):
						special1(0);
					elif Input.is_action_pressed("heavy_attack"):
						special1(1);
					elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
						super._unhandled_input(event);
				
				if current_special == 2:
					#no direction
					if event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y < Global.DEADZONE and direction.y > -Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
						super._unhandled_input(event);
				
				if current_special == 3:
					#down left
					if event is InputEventJoypadMotion and direction.x < -Global.DEADZONE and direction.y < -Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
						super._unhandled_input(event);
			4:
				if current_special == 2:
					#hard right
					if event is InputEventJoypadMotion and direction.x > Global.DEADZONE and direction.y > -Global.DEADZONE and direction.y < Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
						super._unhandled_input(event);
				
				if current_special == 3:
					#hard left
					if event is InputEventJoypadMotion and direction.x < -Global.DEADZONE and direction.y > -Global.DEADZONE and direction.y < Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
						super._unhandled_input(event);
			5:
				if current_special == 2:
					if Input.is_action_pressed("slash_attack"):
						special2();
					elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
						super._unhandled_input(event);
				
				if current_special == 3:
					#up left
					if event is InputEventJoypadMotion and direction.x < -Global.DEADZONE and direction.y > Global.DEADZONE:
						progress_combo();
					elif event is InputEventJoypadButton or event is InputEventKey:
						motion_combo = false;
						super._unhandled_input(event);
			6:
				#hard down
				if event is InputEventJoypadMotion and direction.x > -Global.DEADZONE and direction.x < Global.DEADZONE and direction.y > Global.DEADZONE:
					progress_combo()
				elif event is InputEventJoypadButton or event is InputEventKey:
					motion_combo = false;
					super._unhandled_input(event);
			7:
				#up right
				if event is InputEventJoypadMotion and direction.x > Global.DEADZONE and direction.y > Global.DEADZONE:
					progress_combo();
				elif event is InputEventJoypadButton or event is InputEventKey:
					motion_combo = false;
					super._unhandled_input(event);
			8:
				#hard right
				if event is InputEventJoypadMotion and direction.x > Global.DEADZONE and direction.y > -Global.DEADZONE and direction.y < Global.DEADZONE:
					progress_combo();
				elif event is InputEventJoypadButton or event is InputEventKey:
					motion_combo = false;
					super._unhandled_input(event);
			9:
				if Input.is_action_pressed("heavy_attack"):
					progress_combo();
				elif event is InputEventJoypadButton or event is InputEventKey:
					motion_combo = false;
					super._unhandled_input(event);
			10:
				if Input.is_action_pressed("slash_attack"):
					progress_combo();
				elif event is InputEventJoypadButton or event is InputEventKey:
					motion_combo = false;
					super._unhandled_input(event);
				
	print(motion_combo)
	super._unhandled_input(event);
	if special_step == 0: motion_combo = false;


func create_sword(_position, _scale, _speed, _rotation, absolute=false):
	var sword = swordPath.instantiate();
	sword.position = _position;
	sword.scale = _scale;
	sword.velocity = _speed;
	sword.rotate(_rotation)
	sword.id = id;
	if absolute: get_node("/root/Game/Projectiles").add_child(sword)
	else: $Swords.add_child(sword);
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
		if Input.is_action_just_pressed("jump") and not is_grabbed and not grabbing:
			animation["parameters/conditions/jump"] = true
	else:
		if Input.is_action_just_pressed("jump") and hasDoubleJump and not is_grabbed and not grabbing:
			animation["parameters/conditions/jump"] = true
		else:
			animation["parameters/conditions/jump"] = false

func _on_sword_timer_timeout():
	ready_swords += 1;


func _on_heavy_timer_timeout():
	#normal heavy
	if last_heavy_attack == 0:
		for s in get_node("/root/Game/Projectiles").get_children():
			if s.is_in_group("HeavySwords"):
				s.start_timer(0.3);
				s.velocity.x = 150;
				
	#up right heavy
	if last_heavy_attack == 1:
		for s in get_node("/root/Game/Projectiles").get_children():
			if s.is_in_group("HeavySwords"):
				s.start_timer(0.3);
				s.velocity = Vector2(1, -1)*150;
				
	#down heavy
	if last_heavy_attack == 2:
		for s in get_node("/root/Game/Projectiles").get_children():
			if s.is_in_group("HeavySwords"):
				s.start_timer(0.3);
				s.velocity.y = 150;
				
	for p in $Portals.get_children():
		if p.top_level:
			p.use_portal();
			p.top_level = false;
			p.get_node("ConnectionBox/CollisionShape2D").disabled = false;


func _on_portal_recall_timer_timeout():
	currPortal.velocity.x = 100;
