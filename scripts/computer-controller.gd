extends Node

const DEBUG = false

enum {CHASE,FLEE}
var target
var lastUpdate = 0
var lastInput = 0
const INPUT_LIMIT = 1000
var rng = RandomNumberGenerator.new()
var state = CHASE

func updateState(character):
	if not character or not target: return
	if character.current_balloons < 1:
		state = FLEE
	elif target.current_balloons < 1:
		state = CHASE
	elif distanceBetween(character,target) < 75 and character.position.y > target.position.y - 32: 
		state = FLEE
	else:
		state = CHASE

func getInput(character):
	var input = {
		dirAxis = 0,
		jumped = false
	}
	
	
	if Time.get_ticks_msec() - lastUpdate > INPUT_LIMIT: 
		updateTarget(character)
		updateState(character)
	
	if target and character:
		if state == CHASE: stateChase(character, input)
		if state == FLEE: stateFlee(character, input)
	
	return input

func stateChase(character, input):
	if not character or not target: return
	var directionOfTarget = character.get_global_position().direction_to(target.get_global_position())
	if directionOfTarget.x < -0.25: input.dirAxis = -1
	if directionOfTarget.x > 0.25: input.dirAxis = 1
	
	if Time.get_ticks_msec() - lastInput > 1000:
		if (directionOfTarget.y < 0.5):
			input.jumped = true
			lastInput = Time.get_ticks_msec()

func stateFlee(character, input):
	if not character or not target: return
	var directionOfTarget = character.get_global_position().direction_to(target.get_global_position())
	if directionOfTarget.x < -0.25: input.dirAxis = 1
	if directionOfTarget.x > 0.25: input.dirAxis = -1
	
	if Time.get_ticks_msec() - lastInput > 1000:
		if (directionOfTarget.y < 0.5):
			input.jumped = true
			lastInput = Time.get_ticks_msec()

func updateTarget(character):
	var characters = get_tree().get_nodes_in_group("character").filter(func(c): return c != character)
	# print("other chars:",characters.size())
	if characters.size() < 1: return null
	target = characters.reduce(func(accum: Node, c: Node):
		var current_distance = distanceBetween(character, c)
		var accum_distance = distanceBetween(character, accum)
		if current_distance < accum_distance: return c
		else: return accum
	)
	lastUpdate = Time.get_ticks_msec() + rng.randi_range(-INPUT_LIMIT/4, INPUT_LIMIT/4)

func distanceBetween(c1,c2):
	return c1.get_global_position().distance_to(c2.get_global_position())

func debugDraw (character):
	if not DEBUG: return
	if is_instance_valid(target) and is_instance_valid(character) : 
		character.draw_line(Vector2.ZERO, target.get_global_position()-character.get_global_position(), Color(0,0,0.2), 1)
	else: character.draw_line(Vector2(-10,10), Vector2(10,10), Color(0,255,255), 2)
	
	if (state == CHASE): character.draw_circle(Vector2(15,-15),1,Color(1,0,0))
	if (state == FLEE): character.draw_circle(Vector2(15,-15),1,Color(1,1,0))
