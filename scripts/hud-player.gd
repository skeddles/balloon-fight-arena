extends MarginContainer
class_name PlayerHUD

var character:Character
var arenaScene = find_parent("Level")

func initialize(numberOfPlayers):
	print("init hud",numberOfPlayers)
	get_node("Contents/PlayerNumber").text = "P"+str(character.playerNumber)
	add_theme_constant_override("margin_left", 50)
	add_theme_constant_override("margin_right", 50)
	$Contents/PlayerSprite.texture = character.get_node("Sprite").sprite_frames.get_frame_texture("idle",0)
	$Contents/BalloonSprite.texture = character.get_node("Balloons").sprite_frames.get_frame_texture("2_idle",1)
	update()
	visible = true

func update():
	print("updating hud for p",str(character.playerNumber))
	if not character: return
	
	# Reset
	get_node("Contents/NoBalloons").visible = false
	get_node("Contents/Dead").visible = false
	for i in range(1,11):
		get_node("Contents/Balloon"+str(i)).visible = false
	setBalloonCounterVisibility(false)
	
	# Show Dead Symbol
	if (character.falling):
		print("marking p",str(character.playerNumber)," as dead")
		get_node("Contents/Dead").visible = true
		return
		
	# Update Balloon Counter
	if character.stored_balloons > 10:
		print("more than 10 balloons")
		get_node("Contents/BalloonCounter").text = "x"+str(character.stored_balloons)
		setBalloonCounterVisibility(true)
	elif character.stored_balloons > 1:
		print("1-10 balloons")
		for i in range(1,character.stored_balloons+1):
			get_node("Contents/Balloon"+str(i)).visible = true
	else:
		print("0 balloons")
		get_node("Contents/NoBalloons").visible = true

func setBalloonCounterVisibility(visibility):
	get_node("Contents/BalloonCounter").visible = visibility
	for i in range(1,6):
		get_node("Contents/CountBalloon"+str(i)).visible = visibility
