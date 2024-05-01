extends Node2D

const MAX_PLAYERS = 4



var charactersList = Array(DirAccess.get_files_at("res://scenes/characters"))

func _ready():
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
