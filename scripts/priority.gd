extends Node

enum {IDLE,CHASE,FLEE,FILL,AVOID}

func calculateRefillPriority(distance, enemy_position, balloons):
	var distScore = 640.0 * pow(2, log(distance / 640.0))
	var ballScore = pow(12,4-balloons)
	var eposScore = (1-enemy_position)*0.75 #pow(2,1-enemy_position)-1
	return round(distScore + ballScore) * eposScore * 1.5

func calculateFleePriority(distance, enemy_position, balloons):
	var distScore = 280.0 * pow(4, -log(distance / 280.0))
	var ballScore = pow(10,4-balloons)
	var eposScore = 1-enemy_position #pow(2,1-enemy_position)-1
	print("calculateFleePriority=",round(distScore + ballScore) * eposScore,"| ",distance,", ",enemy_position,", ", balloons)
	return round(distScore + ballScore) * eposScore

func calculateAttackPriority(distance, enemy_position, balloons):
	var distScore = 640.0 * pow(2, -log(distance / 640.0))
	var ballScore = pow(14,balloons/1.05)
	var eposScore = 1.25+enemy_position #pow(2,1-enemy_position)-1
	print("calculateAttackPriority=",round(distScore + ballScore) * eposScore,"| ",distance,", ",enemy_position,", ", balloons)
	return round(distScore + ballScore) * eposScore
	
func calculateAvoidPriority(distance, enemy_position, balloons,velocity):
	print("lindvel",velocity)
	if distance > 128: return 1
	var distScore = 128.0 * pow(velocity, -log(distance / 128.0))
	var ballScore = pow(10,4-balloons)
	return round(distScore + ballScore) / 2
