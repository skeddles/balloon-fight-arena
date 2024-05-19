extends Node2D

func _ready():
	$TitleMusic.play()
	$Version.text = "V"+ ProjectSettings.get_setting("application/config/version")

func _on_arena_button_pressed():
	var arenaSetupScreen = load("res://scenes/debug_launcher.tscn").instantiate()
	get_tree().root.add_child(arenaSetupScreen)
	visible = false

func _on_balloon_trip_button_pressed():
	var balloonTripScreen = load("res://scenes/balloon-trip.tscn").instantiate()
	get_tree().root.add_child(balloonTripScreen)
	suspend()

func suspend():
	visible = false
	$TitleMusic.stop()
	
func resumeMusic():
	$TitleMusic.play(0)

func restart():
	visible = true
	$TitleMusic.play(0)
