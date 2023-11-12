extends Node2D

var rotating = 0;

func _ready():
	$Node/Select2/Versus.disabled = true
	$Node/Select2/Train.disabled = true
	$Node/Select2/Back.disabled = true
	
	$Title.modulate.a = 1;

func _physics_process(delta):
	if rotating == 1: $Title.modulate.a -= 2.8*delta
	elif rotating == -1: $Title.modulate.a += 2.8*delta

func _on_quit_pressed():
	get_tree().quit()

func _on_play_pressed():
	var tween = get_tree().create_tween();
	tween.tween_property($Node, "rotation_degrees", 180, .5);
	rotating = 1;
	
	
	$Node/Select1/Play.disabled = true
	$Node/Select1/Options.disabled = true
	$Node/Select1/Quit.disabled = true
	
	$Node/Select2/Versus.disabled = false
	$Node/Select2/Train.disabled = false
	$Node/Select2/Back.disabled = false
	
	await tween.finished;
	rotating = 0;

func _on_back_pressed():
	var backTween = get_tree().create_tween();
	backTween.tween_property($Node, "rotation_degrees", 0, .5);
	rotating = -1;
	
	$Node/Select2/Versus.disabled = true
	$Node/Select2/Train.disabled = true
	$Node/Select2/Back.disabled = true
	
	$Node/Select1/Play.disabled = false
	$Node/Select1/Options.disabled = false
	$Node/Select1/Quit.disabled = false
	
	await backTween.finished;
	rotating = 0;


