extends Node

var Cooldown = preload("res://scripts/cpu/util/cooldown.gd").new()
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
	Cooldown.ifCool("updateTarget", 100, func(): 
		updateAttackTarget(character)
	)
	MoveTowardsPoint.adjustInput(input, character, attackTargetPoint, attackTargetDirection)
	
func updateAttackTarget(character):
	character.get_node("NavigationAgent2D").target_position = target.position
	attackTargetPoint = character.get_node("NavigationAgent2D").get_next_path_position() + Vector2(0,-10)
	attackTargetDirection = character.to_local(character.get_node("NavigationAgent2D").get_next_path_position()).normalized()
	last_update_target = Time.get_ticks_msec() + RNG.randi_range(-UPDATE_TARGET_FREQUENCY/4, UPDATE_TARGET_FREQUENCY/4)

func debugDraw(character):
	if not is_instance_valid(target): return
	var tarPos = target.get_global_position()-character.get_global_position()
	character.draw_line(Vector2.ZERO, tarPos, Color(0.3,0,0), 2)
	character.draw_line(Vector2.ZERO, attackTargetDirection * 64, Color.RED, 2)
	
	character.draw_circle(tarPos, 6, Color.WHITE)
	character.draw_circle(tarPos, 4, Color.RED)
	character.draw_circle(tarPos, 2, Color.WHITE)
	character.draw_circle(tarPos, 1, Color.RED)
	
