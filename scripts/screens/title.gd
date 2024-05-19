extends Node2D

@onready var settingsScreen = load("res://scenes/screens/settings.tscn").instantiate()

func _ready():
	$TitleMusic.play()
	$Version.text = "V"+ ProjectSettings.get_setting("application/config/version")
	
	settingsScreen.visible = false
	get_tree().root.add_child.call_deferred(settingsScreen)

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


func _on_settings_button_pressed():
	settingsScreen.visible = true
	visible = false

func reloadScene(scene, path):
	scene.queue_free()
	await scene.tree_exited
	var newScene = load(path).instantiate()
	get_tree().root.add_child(newScene)
