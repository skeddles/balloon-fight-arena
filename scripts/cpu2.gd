extends Node
var Cooldown = preload("res://scripts/cpu/util/cooldown.gd").new()
var StateIdle = preload("res://scripts/cpu/state-idle.gd").new()
var StateFlee = preload("res://scripts/cpu/state-flee.gd").new()
var StateAttack = preload("res://scripts/cpu/state-attack.gd").new()
var StateFill = preload("res://scripts/cpu/state-fill.gd").new()
var StateAvoid = preload("res://scripts/cpu/state-avoid.gd").new()

var state = StateIdle

const hazardTileList = [Vector2(7,2), Vector2(8,2),Vector2(9,2), Vector2(10,2), Vector2(8,22)]
@onready var hazardTiles = getAllHazardTilesOnMap()
func getAllHazardTilesOnMap():
	var hazardTilesFound = []
	var map = get_node("/root/Level/TileMap")
	for hazTileCoordinates in hazardTileList:
		var matchingTiles = map.get_used_cells_by_id(0,0,hazTileCoordinates)
		hazardTilesFound += matchingTiles
	return hazardTilesFound

func getInput(character):
	var input = {
		dirAxis = 0,
		jumped = false,
		fill = false,
		action = false
	}
	
	Cooldown.ifCool("updateState", 100, func(): updateState(character))
	state.getInput(input, character)
	return input

func updateState(character):
	var priority = {state = StateIdle, score = -1, target = null}
	
	# Check all hazards
	for tile in hazardTiles:
		var hazardScore = StateAvoid.calculatePriority(character.position.distance_to(tile*8), character.current_balloons, character.velocity.length())
		if hazardScore > priority.score: priority = {state=StateAvoid, score=hazardScore, target=tile*8}
		
	#Check all enemies
	var otherCharacters = get_tree().get_nodes_in_group("character").filter(func(c): return c != character)
	for enemy in otherCharacters:
		var dist = character.get_global_position().distance_to(enemy.get_global_position())
		var enemyDirection = (character.position - enemy.position).normalized().dot(Vector2.UP)
		
		# Flee
		var fleeScore = StateFlee.calculatePriority(dist, enemyDirection, character.current_balloons)
		if fleeScore > priority.score: priority = {state=StateFlee, score=fleeScore, target=enemy}
		
		# Refill
		if character.stored_balloons > 0 and character.current_balloons < 4:
			var refillScore = StateFill.calculatePriority(dist, enemyDirection, character.current_balloons)
			if refillScore > priority.score: priority = {state=StateFill, score=refillScore, target=enemy}
		
		# Attack
		var attackScore = StateAttack.calculatePriority(dist, enemyDirection, character.current_balloons)
		if attackScore > priority.score: priority = {state=StateAttack, score=attackScore, target=enemy}

	state = priority.state
	state.target = priority.target

const DEBUG = false
func debugDraw (character):
	if not DEBUG or not state: return

	var stateName = state.script.resource_path.replace("res://scripts/cpu/state-","").replace(".gd","")
	character.draw_string(ThemeDB.fallback_font, Vector2(-15, -15), str(stateName), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
		
	if state.has_method("debugDraw"): state.debugDraw(character)
	
	#if get_node("/root/Level/DebugDraw"):
	#	get_node("/root/Level/DebugDraw").rects = []
	#	for ht in hazardTiles:
	#		get_node("/root/Level/DebugDraw").rects.append([Rect2(ht.x*8,ht.y*8, 8,8), Color(1,1,0,0.5)])
