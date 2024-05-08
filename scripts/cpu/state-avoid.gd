extends Node
var Cooldown = preload("res://scripts/cpu/util/cooldown.gd").new()
var Escape = preload("res://scripts/cpu/util/escape.gd").new()
var MoveTowardsPoint = preload("res://scripts/cpu/util/move-towards-point.gd").new()

const MAX_DISTANCE = 96

var target
var avoidTileDirection
var avoidTilePoint

func calculatePriority(distance, balloons, velocity):
	if distance > MAX_DISTANCE: return 1
	var distScore = MAX_DISTANCE * pow(velocity*4, -log(distance / MAX_DISTANCE))
	var ballScore = pow(10,4-balloons)
	return round(distScore + ballScore) / 2

func getInput(input, character):
	if not character or not target: return
	Cooldown.ifCool("updateTarget", 100, func(): 
		var newAvoidTarget = Escape.getNewFleeTarget(character, target)
		avoidTilePoint = newAvoidTarget[0]
		avoidTileDirection = newAvoidTarget[1]
	)
	MoveTowardsPoint.adjustInput(input, character, target, avoidTileDirection)

func debugDraw(character):
	if not target: return
	var pos = character.get_global_position()
	character.draw_rect(Rect2(target.x-pos.x+2, target.y-pos.y+2, 4, 4), Color.MAGENTA)
	character.draw_circle(avoidTilePoint-pos, 8, Color.GREEN)
