extends Node

const INPUT_COOLDOWN = 100
var last_input = 0

var target

func calculatePriority(distance, enemy_position, balloons):
	var distScore = 640.0 * pow(2, log(distance / 640.0))
	var ballScore = pow(12,4-balloons)
	var eposScore = (1-enemy_position)*0.75 #pow(2,1-enemy_position)-1
	return round(distScore + ballScore) * eposScore * 1.5

func getInput(input, character):
	if character.is_on_floor():
		if Time.get_ticks_msec() - last_input > INPUT_COOLDOWN:
			input.fill = true


