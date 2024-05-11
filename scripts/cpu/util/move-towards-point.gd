extends Node
var Cooldown = preload("res://scripts/cpu/util/cooldown.gd").new()

func adjustInput(input, character, point, direction):
	var currentAxis = 1 if character.get_node("Sprite").flip_h else -1
	var desiredAxis = round(direction.x)
	
	if desiredAxis != currentAxis:
		Cooldown.ifCool("flipSprite", 200, func(): 
			if direction.x < -0.1: input.dirAxis = -1
			if direction.x > 0.1: input.dirAxis = 1
		)
	else:
		input.dirAxis = currentAxis
	
	if (direction.y < 0): 
		Cooldown.ifCool("lastInput", 150, func(): 
			input.jumped = true
			print("jumpt",input.dirAxis)
		)

	
