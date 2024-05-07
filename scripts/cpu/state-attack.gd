extends Node
var MoveTowardsPoint = preload("res://scripts/cpu/util/move-towards-point.gd").new()

const UPDATE_TARGET_FREQUENCY = 100
var RNG = RandomNumberGenerator.new()

var last_update_target = 0
var target
var attackTargetPoint
var attackTargetDirection


func calculatePriority(distance, enemy_position, balloons):
	var distScore = 640.0 * pow(2, -log(distance / 640.0))
	var ballScore = pow(14,balloons/1.05)
	var eposScore = 1.25+enemy_position #pow(2,1-enemy_position)-1
	return round(distScore + ballScore) * eposScore

func getInput(input, character):
	if not character or not target: return
	if shouldUpdateAttackTarget(): 
		target = updateAttackTarget(character)
	MoveTowardsPoint.adjustInput(input, character, attackTargetPoint, attackTargetDirection)
	
func updateAttackTarget(character):
	if not character or not target: return
	character.get_node("NavigationAgent2D").target_position = target.position
	attackTargetPoint = character.get_node("NavigationAgent2D").get_next_path_position() + Vector2(0,-10)
	attackTargetDirection = character.to_local(character.get_node("NavigationAgent2D").get_next_path_position()).normalized()
	last_update_target = Time.get_ticks_msec() + RNG.randi_range(-UPDATE_TARGET_FREQUENCY/4, UPDATE_TARGET_FREQUENCY/4)
	
func shouldUpdateAttackTarget():
	return Time.get_ticks_msec() - last_update_target > UPDATE_TARGET_FREQUENCY

func debugDraw(character):
	if not target: return
	character.draw_line(Vector2.ZERO, target.get_global_position()-character.get_global_position(), Color(0.3,0,0), 2)

