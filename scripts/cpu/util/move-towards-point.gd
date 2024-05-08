extends Node
var Cooldown = preload("res://scripts/cpu/util/cooldown.gd").new()

func adjustInput(input, character, point, direction):
	var currentAxis = 1 if character.get_node("Sprite").flip_h else -1
	var desiredAxis = round(direction.x)
	
	if desiredAxis != currentAxis:
		Cooldown.ifCool("flipSprite", 200, func(): 
			input.dirAxis = round(direction.x)
		)
	else:
		input.dirAxis = currentAxis
	
	Cooldown.ifCool("lastInput", 150, func(): 
		if (point.y < character.position.y): 
			input.jumped = true
	)
