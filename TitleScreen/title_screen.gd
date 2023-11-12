extends Node2D

var rotating = 0;

func _ready():
	$Node/Versus.disabled = true
	$Node/Train.disabled = true
	$Node/Back.disabled = true
	$OptionsMenu.hide();#lolol
	$Title.modulate.a = 1;

func _physics_process(delta):
	if $OptionsMenu/Volume.value <= -20: $BGM.playing = false;
	elif $BGM.playing == false: $BGM.playing = true;
	$BGM.volume_db = $OptionsMenu/Volume.value;#IT'S JUST A VALUE
	
	if rotating == 1: $Title.modulate.a -= 2.8*delta
	elif rotating == -1: $Title.modulate.a += 2.8*delta

func _on_play_pressed():
	var tween = get_tree().create_tween();
	tween.tween_property($Node, "rotation_degrees", 180, .5);
	rotating = 1;
	
	
	$Node/Play.disabled = true
	$Node/Options.disabled = true
	$Node/Quit.disabled = true
	
	$Node/Versus.disabled = false
	$Node/Train.disabled = false
	$Node/Back.disabled = false
	
	await tween.finished;
	rotating = 0;

func _on_options_pressed():
	#volume.
	#so first off. so okay. so you want to have a volume slider
	#
	#	
	$Node.hide();
	$OptionsMenu.show();
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()

func _on_back_pressed():
	var backTween = get_tree().create_tween();
	backTween.tween_property($Node, "rotation_degrees", 0, .5);
	rotating = -1;
	
	$Node/Versus.disabled = true
	$Node/Train.disabled = true
	$Node/Back.disabled = true
	
	$Node/Play.disabled = false
	$Node/Options.disabled = false
	$Node/Quit.disabled = false
	
	await backTween.finished;
	rotating = 0;

func _on_options_back_pressed():
	$Node.show();
	$OptionsMenu.hide();
	pass # Replace with function body.


func _on_keybinds_button_pressed():
	#Rafe will add this later, he is too tired right now
	pass
	
