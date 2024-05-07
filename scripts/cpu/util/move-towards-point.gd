extends Node

const INPUT_COOLDOWN = 200
var last_input = 0

func adjustInput(input, character, point, direction):
	input.dirAxis = round(direction.x)
	if Time.get_ticks_msec() - last_input > INPUT_COOLDOWN: 
		if (point.y < character.position.y): 
			input.jumped = true
			last_input = Time.get_ticks_msec()
