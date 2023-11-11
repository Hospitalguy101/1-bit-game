extends Node2D
var rotate = false
var rotate2 = false

func _ready():
	$Select2/Versus.disabled = true
	$Select2/Train.disabled = true
	$Select2/Back.disabled = true

func _physics_process(delta):
	if rotate == true:
		if ($Select1.rotation_degrees < -180):
			rotate = false
			$Select2/Versus.disabled = false
			$Select2/Train.disabled = false
			$Select2/Back.disabled = false
		$Title.modulate.a -= 3*delta
		$Select1.rotation_degrees -= 70*delta
		$Select2.rotation_degrees -= 70*delta
	if rotate2 == true:
		if ($Select1.rotation_degrees > 0):
			rotate2 = false
			$Select1/Play.disabled = false
			$Select1/Options.disabled = false
			$Select1/Quit.disabled = false
		$Title.modulate.a += 3*delta
		$Select1.rotation_degrees += 70*delta
		$Select2.rotation_degrees += 70*delta
		

func _on_quit_pressed():
	get_tree().quit()

func _on_play_pressed():
	rotate = true
	$Select1/Play.disabled = true
	$Select1/Options.disabled = true
	$Select1/Quit.disabled = true

func _on_back_pressed():
	rotate2 = true
	$Select2/Versus.disabled = true
	$Select2/Train.disabled = true
	$Select2/Back.disabled = true
