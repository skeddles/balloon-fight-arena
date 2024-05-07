extends Node

var Escape = preload("res://scripts/cpu/util/escape.gd").new()
var MoveTowardsPoint = preload("res://scripts/cpu/util/move-towards-point.gd").new()

const UPDATE_TARGET_FREQUENCY = 250
var last_update_target = 0

var target
var avoidTileDirection

func calculatePriority(distance, balloons, velocity):
	if distance > 128: return 1
	var distScore = 128.0 * pow(velocity, -log(distance / 128.0))
	var ballScore = pow(10,4-balloons)
	return round(distScore + ballScore) / 2

func getInput(input, character):
	if not character or not target: return
	if Time.get_ticks_msec() - last_update_target > UPDATE_TARGET_FREQUENCY: 
		var newAvoidTarget = Escape.getNewFleeTarget(character, target)
		target = newAvoidTarget[0]
		avoidTileDirection = newAvoidTarget[1]
	MoveTowardsPoint.adjustInput(input, character, target, avoidTileDirection)
