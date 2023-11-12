extends Fighter

var ready_swords = 8;
@onready var swordPath = load("res://Characters/Rin/sword.tscn")

func _physics_process(delta):
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
