extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera/UI/ready.visible = true;
	$ReadyTimer.start();
	$Camera/UI/fight.visible = false;


func play_sfx(sfx):
	if sfx == "hit": 
		$SFX.stream = load("res://Music/Sound Effects/HitSound1.mp3");
	if sfx == "woosh":
		$SFX.stream = load("res://Music/Sound Effects/WooshSound.mp3");
	$SFX.play();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Camera/UI/time.text = str(int($MatchTime.time_left));

func _on_ready_timer_timeout():
	$Camera/UI/ready.visible = false;
	$Camera/UI/fight.visible = true;
	$GoTimer.start();

func _on_go_timer_timeout():
	$Camera/UI/fight.visible = false;
	$MatchTime.start();

func _on_match_time_timeout():
	pass # Replace with function body.
