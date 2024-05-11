extends Node
var Escape = preload("res://scripts/cpu/util/escape.gd").new()
var MoveTowardsPoint = preload("res://scripts/cpu/util/move-towards-point.gd").new()
var Cooldown = preload("res://scripts/cpu/util/cooldown.gd").new()

const UPDATE_TARGET_FREQUENCY = 250

var last_update_target = 0
var target
var fleeTargetPoint
var fleeTargetDirection

func calculatePriority(distance, enemy_position, balloons):
	var distScore = 280.0 * pow(4, -log(distance / 280.0))
	var ballScore = pow(10,4-balloons)
	var eposScore = 1-enemy_position #pow(2,1-enemy_position)-1
	return round(distScore + ballScore) * eposScore

func getInput(input, character):
	if not character or not target: return
	Cooldown.ifCool("updateTarget", 250, func(): 
		var newFleeTarget = Escape.getNewFleeTarget(character, target.position)
		fleeTargetPoint = newFleeTarget[0]
		fleeTargetDirection = newFleeTarget[1]
	)
	MoveTowardsPoint.adjustInput(input, character, fleeTargetPoint, fleeTargetDirection)
	
func debugDraw(character):
	character.draw_line(Vector2.ZERO, target.get_global_position()-character.get_global_position(), Color(0,0.3,0.3), 2)
	character.draw_circle(fleeTargetPoint-character.get_global_position(), 8, Color(1,0,1,0.3))
	
	for t in Escape.getPossibleTargets():
		var s = round(Escape.getEscapeRouteQuality(character,t,target.position).score)
		character.draw_circle(t,s/16,Color(0,1,1,0.3))
		character.draw_string(ThemeDB.fallback_font,t, str(s), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
