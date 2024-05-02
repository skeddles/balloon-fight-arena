extends Node2D

const MAX_PLAYERS = 4

var inputSchemes = ["disabled","wasd","arrows","numpad","ijkl"]
const NUMBER_OF_CONTROLLERS = 4
var charactersList = Array(DirAccess.get_files_at("res://scenes/characters"))

var NUMBER_OF_STATIC_CONTROL_SCHEMES = inputSchemes.size()
var NUMBER_OF_CONTROL_SCHEMES = inputSchemes.size() + NUMBER_OF_CONTROLLERS + 1

func _ready():
	$TitleMusic.play()
	$Version.text = "V"+ ProjectSettings.get_setting("application/config/version")
	var characterDropdowns = get_tree().get_nodes_in_group("characterDropdown")
	for f in charactersList:
		var path = "res://scenes/characters/"+f.replace('.remap', '')
		var scene = load(path)
		var instance = scene.instantiate()
		for dropdown in characterDropdowns:
			dropdown.add_item(instance.CharacterName.to_upper())
			var icon_atlas = AtlasTexture.new()
			icon_atlas.atlas = instance.SpriteSheet
			icon_atlas.region = Rect2(8,8,16,16)
			print(icon_atlas)
			dropdown.set_item_icon(dropdown.item_count-1,icon_atlas)
	var inputDropdowns = get_tree().get_nodes_in_group("inputDropdown")
	
	for c in range(1,NUMBER_OF_CONTROLLERS+1):
		inputSchemes.append("controller "+str(c))
	inputSchemes.append("cpu")
	
	for dropdown in inputDropdowns:
		for i in inputSchemes:
			dropdown.add_item(i.to_upper())
		if (inputDropdowns.find(dropdown)==0):
			dropdown.selected = 1
		else:
			dropdown.selected = NUMBER_OF_CONTROL_SCHEMES-1
		

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
	var balloonCount = int($BalloonCount.value)
	var enabledCharacters = []
	for i in range(1,MAX_PLAYERS+1):
		print("char",i," P"+str(i)+"Input")
		print(get_node("P"+str(i)+"Input"))
		var controlSelection = get_node("P"+str(i)+"Input").selected
		var characterSelection = get_node("P"+str(i)+"Char").selected
		if controlSelection != 0:
			# Create Character
			print(characterSelection,charactersList[characterSelection])
			var character = load("res://scenes/characters/"+charactersList[characterSelection]).instantiate()
			arenaScene.add_child(character)
			character.position = arenaScene.find_child("Spawn"+str(i)).position
			character.playerNumber = i
			character.playerHUD = arenaScene.get_node("HUD/PlayerList/Player"+str(character.playerNumber))
			character.playerHUD.character = character
			enabledCharacters.append(character)
			
			# Set Balloons
			if balloonCount > 4:
				if $StartFilled.button_pressed:
					character.current_balloons = 4
					character.stored_balloons = balloonCount - 4
				else:
					character.stored_balloons = balloonCount
			else:
				if $StartFilled.button_pressed:
					character.current_balloons = balloonCount
				else:
					character.stored_balloons = balloonCount

			# Attach Controller
			var controller
			if controlSelection == NUMBER_OF_CONTROL_SCHEMES-1: 
				controller = preload("res://scenes/cpu.tscn").instantiate()
			else:
				controller = preload("res://scenes/human.tscn").instantiate()
				print ("attach controller? ", controlSelection, " ", inputSchemes.size()," ",  inputSchemes.size() - NUMBER_OF_CONTROLLERS - 1, " ", NUMBER_OF_STATIC_CONTROL_SCHEMES)
				if controlSelection >= NUMBER_OF_STATIC_CONTROL_SCHEMES:
					controller.InputScheme = "controller"
					controller.usingGamePad = true
					controller.gamepadId = controlSelection - NUMBER_OF_STATIC_CONTROL_SCHEMES
					print("shit you chose controller?",controller.gamepadId)
				else:
					controller.InputScheme = inputSchemes[controlSelection]
			character.add_child(controller)
			character.controller = controller
			character.init()
			
	for character in enabledCharacters:
		character.playerHUD.initialize(enabledCharacters.size())
	get_node("/root/DebugLauncher").queue_free()

func checkAtLeast2CharactersSelected():
	var charactersSelected = 0
	if $P1Input.selected != 0: charactersSelected+=1
	if $P2Input.selected != 0: charactersSelected+=1
	if $P3Input.selected != 0: charactersSelected+=1
	if $P4Input.selected != 0: charactersSelected+=1
	return charactersSelected > 1

func checkForDuplicateInputMethods():
	if $P1Input.selected != 0 and $P1Input.selected != inputSchemes.size()-1:
		if $P1Input.selected == $P2Input.selected: return "player 1 and player 2"
		if $P1Input.selected == $P3Input.selected: return "player 1 and player 3"
		if $P1Input.selected == $P4Input.selected: return "player 1 and player 4"
	if $P2Input.selected != 0 and $P2Input.selected != inputSchemes.size()-1:
		if $P2Input.selected == $P3Input.selected: return "player 2 and player 3"
		if $P2Input.selected == $P4Input.selected: return "player 2 and player 4"
	if $P3Input.selected != 0 and $P3Input.selected != inputSchemes.size()-1:
		if $P3Input.selected == $P4Input.selected: return "player 3 and player 4"
	return "okay"
