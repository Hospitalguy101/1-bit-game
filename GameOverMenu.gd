extends Control

var selected = 0;
var moved_selector = false;

var enabled = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var direction = Input.get_vector("p1_move_left", "p1_move_right", "p1_jump", "p1_crouch");
	if abs(direction.x) < 0.05 and abs(direction.y) < 0.05:
		moved_selector = false;
	
	if !visible and (get_parent().get_node("Camera/UI/HP1").value == 0 or get_parent().get_node("Camera/UI/HP2").value == 0):
		selected = 0;
		$MenuButton/MenuSelector.show();
		$QuitButton/QuitSelector.hide();
		show();
		$Timer.start(.5);
	
	if !visible: return;
	if enabled:
		if Input.is_action_pressed("p1_light_attack") and selected == 0:
			var title = load("res://Scenes/title_screen.tscn").instantiate();
			get_node("/root/FightingGame").call_deferred("add_child", title);
			get_node("/root/FightingGame/Game").call_deferred("queue_free");
				
		if Input.is_action_pressed("p1_light_attack") and selected == 1:
			get_tree().quit();
	

func _unhandled_input(event):
	#move selector down
	if Input.is_action_pressed("p1_crouch") and !moved_selector:
		print(selected)
		match selected:
			0:
				selected = 1;
				$MenuButton/MenuSelector.hide();
				$QuitButton/QuitSelector.show();
				moved_selector = true;
				return;
			1:
				selected = 0;
				$MenuButton/MenuSelector.show();
				$QuitButton/QuitSelector.hide();
				moved_selector = true;
				return;
				
	#move selector up
	elif Input.is_action_pressed("p1_jump") and !moved_selector:
		print(selected)
		match selected:
			0:
				selected = 1;
				$MenuButton/MenuSelector.hide();
				$QuitButton/QuitSelector.show();
				moved_selector = true;
				return;
			1:
				selected = 0;
				$MenuButton/MenuSelector.show();
				$QuitButton/QuitSelector.hide();
				moved_selector = true;
				return;


func _on_timer_timeout():
	enabled = true;
