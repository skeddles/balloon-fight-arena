extends Node
var Priority = preload("res://scripts/priority.gd").new()

enum {IDLE,ATTACK,FLEE,FILL,AVOID}

const UPDATE_TARGET_FREQUENCY = 100
var last_update_target = 0

var current_state = IDLE
const UPDATE_STATE_FREQUENCY = 100
var last_update_state = 0

var target = {
	point = Vector2.ZERO,
	direction = Vector2.ZERO,
	character = null,
	fleeTargetPoint = Vector2.ZERO,
	fleeTargetDirection = Vector2.ZERO,
}

const INPUT_COOLDOWN = 200
var last_input = 0

var rng = RandomNumberGenerator.new()

func getInput(character):
	var input = {
		dirAxis = 0,
		jumped = false,
		fill = false
	}
	
	if Time.get_ticks_msec() - last_update_state > UPDATE_STATE_FREQUENCY: 
		updateState(character)
		#current_state=FLEE
	
	if current_state == ATTACK: stateAttack(input, character)
	elif current_state == FLEE: stateFlee(input, character)
	elif current_state == FILL: stateFill(input, character)
	elif current_state == AVOID: stateAvoid(input, character)
	
	return input

func stateFill(input, character):
	if character.is_on_floor():
		if Time.get_ticks_msec() - last_input > INPUT_COOLDOWN:
			input.fill = true

func stateAttack(input, character):
	if not character or not target: return
	if Time.get_ticks_msec() - last_update_target > UPDATE_TARGET_FREQUENCY: 
		updateAttackTarget(character)

	setInputsToMoveTowardsTargetPoint(input, character, target.point, target.direction)


func updateAttackTarget(character):
	if not character or not target.character: return
	character.get_node("NavigationAgent2D").target_position = target.character.position
	target.point = character.get_node("NavigationAgent2D").get_next_path_position() + Vector2(0,-10)
	target.direction = character.to_local(character.get_node("NavigationAgent2D").get_next_path_position()).normalized()
	last_update_target = Time.get_ticks_msec() + rng.randi_range(-UPDATE_TARGET_FREQUENCY/4, UPDATE_TARGET_FREQUENCY/4)

func setInputsToMoveTowardsTargetPoint(input, character, point, direction):
	input.dirAxis = round(direction.x)
	if Time.get_ticks_msec() - last_input > INPUT_COOLDOWN: 
		if (point.y < character.position.y): 
			input.jumped = true
			last_input = Time.get_ticks_msec()
			
func stateFlee(input, character):
	if not character or not target.character: return
	if Time.get_ticks_msec() - last_update_target > UPDATE_TARGET_FREQUENCY: 
		updateFleeTarget(character, target.character.position)
	setInputsToMoveTowardsTargetPoint(input, character, target.fleeTargetPoint, target.fleeTargetDirection)
	

func updateFleeTarget (character, escapeFromPoint):
	if not character: return
	var newTarget = [
		getEscapeRouteQuality(character,character.position+Vector2(128,0), escapeFromPoint),
		getEscapeRouteQuality(character,character.position+Vector2(-128,0), escapeFromPoint),
		getEscapeRouteQuality(character,character.position+Vector2(0,-128), escapeFromPoint),
		getEscapeRouteQuality(character,character.position+Vector2(0,128), escapeFromPoint),
		getEscapeRouteQuality(character,character.position+Vector2(128,128), escapeFromPoint),
		getEscapeRouteQuality(character,character.position+Vector2(-128,-128), escapeFromPoint),
		getEscapeRouteQuality(character,character.position+Vector2(-128,128), escapeFromPoint),
		getEscapeRouteQuality(character,character.position+Vector2(128,-128), escapeFromPoint),
	]
	newTarget = newTarget.reduce(func(a,b):return b if b.score>a.score else a,{score=-1})
	
	character.get_node("NavigationAgent2D").target_position = newTarget.position
	target.fleeTargetPoint = character.get_node("NavigationAgent2D").get_next_path_position() + Vector2(0,-10)
	target.fleeTargetDirection = character.to_local(character.get_node("NavigationAgent2D").get_next_path_position()).normalized()
	
	last_update_target = Time.get_ticks_msec() + rng.randi_range(-UPDATE_TARGET_FREQUENCY/4, UPDATE_TARGET_FREQUENCY/4)

func getEscapeRouteQuality(character, escapeLocationOptionPoint:Vector2, escapeFromPoint:Vector2):
	var closestPositionOnLine = getClosestPositionOnLine(character.position,escapeLocationOptionPoint,escapeFromPoint)
	var distanceOfClosestPositionOnLine = distanceBetweenPoint(character.position, closestPositionOnLine)
	var score = closestPositionOnLine.distance_to(escapeFromPoint)
	if character.position.distance_to(escapeFromPoint) > 32:
		score += verticalAnglePoints(escapeFromPoint,escapeLocationOptionPoint)*-24
	if escapeLocationOptionPoint.x < 32: score = score * ((128-abs(escapeLocationOptionPoint.x - 32))/128)
	if escapeLocationOptionPoint.x > 640-32: score = score * ((128-abs(640-32 - escapeLocationOptionPoint.x))/128)
	if escapeLocationOptionPoint.y < 32: score = score * ((128-abs(escapeLocationOptionPoint.y - 32))/128)
	if escapeLocationOptionPoint.y > 360-32: score = score * ((128-abs(360-32 - escapeLocationOptionPoint.y))/128)
	return {
		score =  score,
		position = escapeLocationOptionPoint
	}

func verticalAnglePoints(c1,c2):
	return (c1 - c2).normalized().dot(Vector2.UP)

func getClosestPositionOnLine(l1,l2,targetPos):
	var line_direction = (l2 - l1).normalized()
	var vector_to_object = targetPos - l1
	var distance = line_direction.dot(vector_to_object)
	var distance_along_line = max(32, min(distance, (l2 - l1).length()))
	var closest_position = l1 + distance_along_line * line_direction
	return closest_position

func distanceBetweenPoint(c1,c2):
	return c1.distance_to(c2)
	

func getClosestCharacter(character):
	var characters = get_tree().get_nodes_in_group("character").filter(func(c): return c != character)
	if characters.size() < 1: return null
	var targetCharacter = characters.reduce(func(accum: Node, c: Node):
		var current_distance = distanceBetween(character, c)
		var accum_distance = distanceBetween(character, accum)
		if current_distance < accum_distance: return c
		else: return accum
	)
	return targetCharacter

func stateAvoid(input, character):
	if not character or not target.character: return
	if Time.get_ticks_msec() - last_update_target > UPDATE_TARGET_FREQUENCY: 
		updateFleeTarget(character, target.point)
	setInputsToMoveTowardsTargetPoint(input, character, target.fleeTargetPoint, target.fleeTargetDirection)

func updateState(character):
	var priority = {
		state = -1,
		score = -1,
		target = null
	}
	
	var score = 0
	var otherCharacters = getOtherCharacters(character)
	
	# Check all hazards
	for tile in hazardTiles:
		var hazardScore = Priority.calculateAvoidPriority(character.position.distance_to(tile*8), null, character.current_balloons, character.velocity.length())
		if hazardScore > priority.score: priority = {state=AVOID, score=hazardScore, target={position=tile*8}}
		
	#Check all enemies
	for enemy in otherCharacters:
		var dist = distanceBetween(character, enemy)
		var enemyDirection = (character.position - enemy.position).normalized().dot(Vector2.UP)
		
		# Flee
		var fleeScore = Priority.calculateFleePriority(dist, enemyDirection, character.current_balloons)
		if fleeScore > priority.score: priority = {state=FLEE, score=fleeScore, target=enemy}
		
		# Refill
		if character.stored_balloons > 0 and character.current_balloons < 4:
			var refillScore = Priority.calculateRefillPriority(dist, enemyDirection, character.current_balloons)
			if refillScore > priority.score: priority = {state=FILL, score=refillScore, target=enemy}
		
		# Attack
		var attackScore = Priority.calculateAttackPriority(dist, enemyDirection, character.current_balloons)
		if attackScore > priority.score: priority = {state=ATTACK, score=attackScore, target=enemy}
	
	current_state = priority.state
	if priority.target:
		target.point = priority.target.position
	if is_instance_valid(priority.target):
		target.character = priority.target
		target.direction = character.get_global_position().direction_to(target.point)
	last_update_state = Time.get_ticks_msec()

	
func getOtherCharacters(character): return get_tree().get_nodes_in_group("character").filter(func(c): return c != character)
	
func distanceBetween(c1,c2):
	return c1.get_global_position().distance_to(c2.get_global_position())

func verticalAngle(p1,p2):
	return (p1 - p2).normalized().dot(Vector2.UP)

const hazardTileList = [Vector2(7,2), Vector2(8,2),Vector2(9,2), Vector2(10,2)]
@onready var hazardTiles = getAllHazardTilesOnMap()
func getAllHazardTilesOnMap():
	var hazardTilesFound = []
	var map = get_node("/root/Level/TileMap")
	for hazTileCoordinates in hazardTileList:
		var matchingTiles = map.get_used_cells_by_id(0,0,hazTileCoordinates)
		hazardTilesFound += matchingTiles

	return hazardTilesFound



const DEBUG = false
@onready var default_font = ThemeDB.fallback_font
func debugDraw (character):
	if not character or not target.character: return
	if not DEBUG: return
	var charpos = character.get_global_position()
	if is_instance_valid(target) and is_instance_valid(character): 
		character.draw_line(Vector2.ZERO, target.get_global_position()-charpos, Color(0,0,0.2), 1)
	
	character.draw_string(default_font, Vector2(0, -15), str(current_state), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
	
	#character.draw_circle(target.character.position-charpos, 8, Color(1,0,0,0.3))
	#character.draw_circle(target.point-charpos, 16, Color(0,1,0,0.3))
	
	if get_node("/root/Level/DebugDraw"):
		get_node("/root/Level/DebugDraw").rects = []
		for ht in hazardTiles:
			get_node("/root/Level/DebugDraw").rects.append([Rect2(ht.x*8,ht.y*8, 8,8), Color(1,1,0,0.5)])
	
	if current_state == FLEE:
		character.draw_circle(target.fleeTargetPoint-charpos, 8, Color(1,0,1,0.3))
		var newTarget = [
			Vector2(64,0),
			Vector2(-64,0),
			Vector2(0,-64),
			Vector2(0,64),
			Vector2(64,64),
			Vector2(-64,-64),
			Vector2(-64,64),
			Vector2(64,-64),
		]
		for t in newTarget:
			var s = round(getEscapeRouteQuality(character,t,target.character.position).score)
			character.draw_circle(t,s/16,Color(0,1,1,0.3))
			character.draw_string(default_font,t, str(s), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
	
