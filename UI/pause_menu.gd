extends Control

#0 = play, 1 = menu, 2 = quit
var selected = 0;
var moved_selector = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var direction = Input.get_vector("p1_move_left", "p1_move_right", "p1_jump", "p1_crouch");
	if abs(direction.x) < 0.05 and abs(direction.y) < 0.05:
		moved_selector = false;


func _unhandled_input(event):
	#enable pause menu
	if !visible and Input.is_action_pressed("pause"):
		selected = 0;
		$ResumeButton/ResumeSelector.show();
		$MenuButton/MenuSelector.hide();
		$QuitButton/QuitSelector.hide();
		show();
		get_tree().paused = true;
		return;
	
	if visible:
		#disable pause menu
		if (Input.is_action_pressed("p1_light_attack") and selected == 0) or Input.is_action_pressed("pause"):
			if $ResumeButton/ResumeSelector.visible:
				hide();
				get_tree().paused = false;
				
		if Input.is_action_pressed("p1_light_attack") and selected == 1:
			get_tree().paused = false;
			var title = load("res://Scenes/title_screen.tscn").instantiate();
			get_node("/root/FightingGame").call_deferred("add_child", title);
			get_node("/root/FightingGame/Game").call_deferred("queue_free");
			
		if Input.is_action_pressed("p1_light_attack") and selected == 2:
			get_tree().quit();
			
		
		#move selector down
		if Input.is_action_pressed("p1_crouch") and !moved_selector:
			match selected:
				0:
					selected = 1;
					$ResumeButton/ResumeSelector.hide();
					$MenuButton/MenuSelector.show();
					$QuitButton/QuitSelector.hide();
					moved_selector = true;
				1:
					selected = 2;
					$ResumeButton/ResumeSelector.hide();
					$MenuButton/MenuSelector.hide();
					$QuitButton/QuitSelector.show();
					moved_selector = true;
				2:
					selected = 0;
					$ResumeButton/ResumeSelector.show();
					$MenuButton/MenuSelector.hide();
					$QuitButton/QuitSelector.hide();
					moved_selector = true;
					
		#move selector up
		if Input.is_action_pressed("p1_jump") and !moved_selector:
			match selected:
				0:
					selected = 2;
					$ResumeButton/ResumeSelector.hide();
					$MenuButton/MenuSelector.hide();
					$QuitButton/QuitSelector.show();
					moved_selector = true;
				1:
					selected = 0;
					$ResumeButton/ResumeSelector.show();
					$MenuButton/MenuSelector.hide();
					$QuitButton/QuitSelector.hide();
					moved_selector = true;
				2:
					selected = 1;
					$ResumeButton/ResumeSelector.hide();
					$MenuButton/MenuSelector.show();
					$QuitButton/QuitSelector.hide();
					moved_selector = true;
	
	
