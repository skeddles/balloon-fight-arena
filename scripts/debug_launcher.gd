extends Node2D

const characters = [
	"balloon-fighter-red",
	"balloon-fighter-blue",
	"balloon-bird-pink",
	"balloon-bird-green",
	"balloon-bird-white"
]

func _ready():
	$Version.text = "V"+ ProjectSettings.get_setting("application/config/version")

func _on_start_match_button_pressed():
	if !checkAtLeast2CharactersSelected():
		OS.alert(' you must pick at least two characters','selection error')
		return
	
	var dupInput = checkForDuplicateInputMethods()
	if dupInput != "okay": 
		OS.alert(dupInput + ' cant have the same input method','selection error')
		return
	
	var arenaScene = preload("res://scenes/main.tscn").instantiate()
	
	get_tree().root.add_child(arenaScene)
	for i in range(1,5):
		print("char",i," P"+str(i)+"Input")
		print(get_node("P"+str(i)+"Input"))
		var controlSelection = get_node("P"+str(i)+"Input").selected
		var characterSelection = get_node("P"+str(i)+"Char").selected
		if controlSelection != 0:
			print("load ","res://scenes/characters/"+characters[characterSelection]+".tscn")
			var character = load("res://scenes/characters/"+characters[characterSelection]+".tscn").instantiate()
			arenaScene.add_child(character)
			character.position = arenaScene.find_child("Spawn"+str(i)).position
			character.current_balloons = int($BalloonCount.value)
			character.playerNumber = i
			var controller
			if controlSelection == 5: 
				controller = preload("res://scenes/cpu.tscn").instantiate()
			else:
				controller = preload("res://scenes/human.tscn").instantiate()
				if controlSelection == 1: controller.InputScheme = 'wasd'
				if controlSelection == 2: controller.InputScheme = 'arrows'
				if controlSelection == 3: controller.InputScheme = 'numpad'
				if controlSelection == 4: controller.InputScheme = 'ijkl'
			character.add_child(controller)
			character.controller = controller
			character.init()
	get_node("/root/DebugLauncher").queue_free()

func checkAtLeast2CharactersSelected():
	var charactersSelected = 0
	if $P1Input.selected != 0: charactersSelected+=1
	if $P2Input.selected != 0: charactersSelected+=1
	if $P3Input.selected != 0: charactersSelected+=1
	if $P4Input.selected != 0: charactersSelected+=1
	return charactersSelected > 1

func checkForDuplicateInputMethods():
	if $P1Input.selected != 0 and $P1Input.selected != 5:
		if $P1Input.selected == $P2Input.selected: return "player 1 and player 2"
		if $P1Input.selected == $P3Input.selected: return "player 1 and player 3"
		if $P1Input.selected == $P4Input.selected: return "player 1 and player 4"
	if $P2Input.selected != 0 and $P2Input.selected != 5:
		if $P2Input.selected == $P3Input.selected: return "player 2 and player 3"
		if $P2Input.selected == $P4Input.selected: return "player 2 and player 4"
	if $P3Input.selected != 0 and $P3Input.selected != 5:
		if $P3Input.selected == $P4Input.selected: return "player 3 and player 4"
	return "okay"
