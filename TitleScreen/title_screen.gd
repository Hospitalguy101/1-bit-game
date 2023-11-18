extends Node2D

var rotating = 0;

#white = 1x, orange = 2x, red = 3x, green = 0.5x, blue = 0.25x, purple = no damage
var color_index = 0
var color_list = ["white", "orange", "red", "green", "blue", "purple"];

var device_list = [];

#disables char screen
var debug_mode = true;

#0 = play, 1 = help, 2 = quit, 3 = back, 4 = color, 5 = start 6 = options back
@onready var selector = $Node/Play/PlaySelector;
var moved_selector = false;

func _ready():
#	$Node/Versus.disabled = true
#	$Node/Train.disabled = true
	$Node/Back.disabled = true
	$HelpMenu.hide();
	$Title.modulate.a = 1;

func _physics_process(delta):
	$Node/ColorLabel.text = color_list[color_index];
	
	var direction = Input.get_vector("p1_move_left", "p1_move_right", "p1_jump", "p1_crouch");
	if abs(direction.x) < 0.05 and abs(direction.y) < 0.05:
		moved_selector = false;
	
	if rotating == 1: $Title.modulate.a -= 2.8*delta
	elif rotating == -1: $Title.modulate.a += 2.8*delta
	$Node/Play/PlaySelector.hide();
	$Node/Help/HelpSelector.hide();
	$Node/Quit/QuitSelector.hide();
	$Node/Back/BackSelector.hide();
	$Node/Start/StartSelector.hide();
	$Node/ColorLabel/ColorSelector.hide();
	$HelpMenu/HelpBack/HelpBackSelector.hide();
	selector.show();
	
	get_parent().modulate = Global.color;
	

func _unhandled_input(event):
	if event.is_action_pressed('p1_crouch') and !moved_selector:
		$SFX.play();
		if selector == $Node/Play/PlaySelector:
			selector = $Node/Help/HelpSelector;
			moved_selector = true;
		elif selector == $Node/Help/HelpSelector:
			selector = $Node/Quit/QuitSelector;
			moved_selector = true;
		elif selector == $Node/Quit/QuitSelector:
			selector = $Node/Play/PlaySelector;
			moved_selector = true;
		elif selector == $Node/Back/BackSelector:
			selector = $Node/Start/StartSelector;
			moved_selector = true;
		elif selector == $Node/Start/StartSelector:
			selector = $Node/ColorLabel/ColorSelector;
			moved_selector = true;
		elif selector == $Node/ColorLabel/ColorSelector:
			selector = $Node/Back/BackSelector;
			moved_selector = true;
			
	elif event.is_action_pressed('p1_jump') and !moved_selector:
		$SFX.play();
		if selector == $Node/Play/PlaySelector:
			selector = $Node/Quit/QuitSelector;
			moved_selector = true;
		elif selector == $Node/Help/HelpSelector:
			selector = $Node/Play/PlaySelector;
			moved_selector = true;
		elif selector == $Node/Quit/QuitSelector:
			selector = $Node/Help/HelpSelector
			moved_selector = true;
		elif selector == $Node/Back/BackSelector:
			selector = $Node/ColorLabel/ColorSelector;
			moved_selector = true;
		elif selector == $Node/Start/StartSelector:
			selector = $Node/Back/BackSelector;
			moved_selector = true;
		elif selector == $Node/ColorLabel/ColorSelector:
			selector = $Node/Start/StartSelector;
			moved_selector = true;
			
	elif event.is_action_pressed("p1_light_attack"):
		selector.get_parent().emit_signal("pressed");
		if selector == $Node/Play/PlaySelector:
			selector = $Node/Start/StartSelector;
		elif selector == $Node/Options/OptionsSelector:
			selector = $OptionsMenu/Volume/VolumeSelector;
		elif selector == $Node/Back/BackSelector:
			selector = $Node/Play/PlaySelector;
		elif selector == $HelpMenu/HelpBack/HelpBackSelector:
			selector = $Node/Play/PlaySelector;
			
	elif event.is_action_pressed("p1_move_left") and !moved_selector:
		if selector == $Node/ColorLabel/ColorSelector:
			moved_selector = true;
			_on_color_left_pressed();
				
	elif event.is_action_pressed("p1_move_right") and !moved_selector:
		if selector == $Node/ColorLabel/ColorSelector:
			moved_selector = true;
			_on_color_right_pressed();


func _on_play_pressed():
	var tween = get_tree().create_tween();
	tween.tween_property($Node, "rotation_degrees", 180, .5);
	rotating = 1;
	
	
	$Node/Play.disabled = true
	$Node/Help.disabled = true
	$Node/Quit.disabled = true
	
#	$Node/Versus.disabled = false
#	$Node/Train.disabled = false
	$Node/Back.disabled = false
	
	await tween.finished;
	rotating = 0;

func _on_options_pressed():
	$Node.hide();
	$OptionsMenu.show();
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()

func _on_back_pressed():
	var backTween = get_tree().create_tween();
	backTween.tween_property($Node, "rotation_degrees", 0, .5);
	rotating = -1;
	
#	$Node/Versus.disabled = true
#	$Node/Train.disabled = true
	$Node/Back.disabled = true
	
	$Node/Play.disabled = false
	$Node/Help.disabled = false
	$Node/Quit.disabled = false
	
	await backTween.finished;
	rotating = 0;

func _on_options_back_pressed():
	$Node.show();
	$HelpMenu.hide();


func _on_color_left_pressed():
	color_index -= 1;
	if color_index < 0: color_index = 5;
	match color_index:
		0:
			Global.color_modifier = 1;
		1:
			Global.color_modifier = 2;
		2:
			Global.color_modifier = 3;
		3:
			Global.color_modifier = 0.5;
		4:
			Global.color_modifier = 0.25;
		5:
			Global.color_modifier = 0;
	$Node/ColorLabel/Label.text = str(Global.color_modifier) + " x  DAMAGE";


func _on_color_right_pressed():
	color_index += 1;
	if color_index > 5: color_index = 0;
	match color_index:
		0:
			Global.color_modifier = 1;
		1:
			Global.color_modifier = 2;
		2:
			Global.color_modifier = 3;
		3:
			Global.color_modifier = 0.5;
		4:
			Global.color_modifier = 0.25;
		5:
			Global.color_modifier = 0;
	$Node/ColorLabel/Label.text = str(Global.color_modifier) + " x  DAMAGE";
	

func _on_start_pressed():
	if debug_mode:
		var game = load("res://Scenes/game.tscn").instantiate();
		for p in game.get_node("Players").get_children():
			if p.id == 0:
				Global.players[0] = p;
			else:
				Global.players[1] = p;
		get_parent().add_child(game);
		call_deferred("queue_free");
	else: $CharacterSelect.show();
	
