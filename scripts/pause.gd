extends Node2D

func _ready():
	visible=false

func _process(_delta):
	if Input.is_action_just_pressed("pause"): toggle()

func toggle():
	if get_tree().paused: unpause()
	else: pause()

func pause():
	get_tree().paused = true
	$PauseSound.play()
	visible=true
	
func unpause():
	get_tree().paused = false
	$PauseSound.play()
	visible=false

func exit():
	get_tree().paused = false
	visible=false
	GlobalSignal.pause_menu_exit.emit()
