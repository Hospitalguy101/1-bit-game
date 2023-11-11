extends Fighter

var ready_swords = [];

func _physics_process(delta):
	ready_swords = [];
	for s in $Swords.get_children():
		if s.isReady:
			ready_swords.append(s);
	
	super._physics_process(delta);
	

func light_attack(direction):
	#check is sword is availible
	if ready_swords.size() > 0:
		#stick tilted left
		if direction.x < -1*Global.DEADZONE:
			#quick forwards attack
			var sword = ready_swords[0];
			sword.position.x = 20;
			sword.position.y = 0;
			sword.rotation = 0;
			sword.attacking = true;
			
		#stick tilted up right
		elif direction.x > Global.DEADZONE and direction.y > Global.DEADZONE:
			pass
		
		#stick tilted down
		elif direction.y < -1*Global.DEADZONE:
			pass
			
		#default move
		else:
			pass
