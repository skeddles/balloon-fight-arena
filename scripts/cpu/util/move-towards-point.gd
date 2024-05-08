extends Node
var Cooldown = preload("res://scripts/cpu/util/cooldown.gd").new()

func adjustInput(input, character, point, direction):
	input.dirAxis = round(direction.x)
	Cooldown.ifCool("lastInput", 50, func(): 
		if (point.y < character.position.y): 
			input.jumped = true
	)
