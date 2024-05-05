@tool
extends Node2D

@export var character1:Sprite2D
@export var character2:Sprite2D
@export var balloon_count:int = 2
@onready var default_font = ThemeDB.fallback_font
func _draw():
	#draw_line(Vector2.ZERO,Vector2(20,20),Color.RED,1.0)
	drawData(character1)
	#drawData(character2)
	pass

func drawData(character):
	var data = character.name

	#draw_string(default_font, character.position+Vector2(-50, 15+10*0), str(character.name), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
	#draw_string(default_font, character.position+Vector2(-50, 15+10*1), str(character.position), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
	
	var avd = calculateAvoidPriority(distanceBetweenPoint(character1.position, Vector2(20*8,32*8)), null, balloon_count)
	var atk = calculateAttackPriority(distanceBetween(character1,character2), verticalAngle(character1,character2), balloon_count)
	var flee = calculateFleePriority(distanceBetween(character1,character2), verticalAngle(character1,character2), balloon_count)
	updateFleeTarget()
	var highest = 'atk' 
	if flee > atk: highest = 'flee'
	if avd > flee: highest = 'avd'
	draw_string(default_font, character.position+Vector2(-50, 15+10*2)," attack: "+str(atk), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.RED if highest=='atk' else Color.WHITE  )
	draw_string(default_font, character.position+Vector2(-50, 15+10*3)," flee: "+str(flee), HORIZONTAL_ALIGNMENT_CENTER, -1, 8,  Color.RED if highest=='flee' else Color.WHITE  )
	draw_string(default_font, character.position+Vector2(-50, 15+10*4)," avoid: "+str(avd), HORIZONTAL_ALIGNMENT_CENTER, -1, 8,  Color.RED if highest=='avd' else Color.WHITE  )
	

func _process(delta):
	queue_redraw()

func calculateRefillPriority(distance, enemy_position, balloons):
	var distScore = 640.0 * pow(2, log(distance / 640.0))
	var ballScore = pow(12,4-balloons)
	var eposScore = (1-enemy_position)*0.75 #pow(2,1-enemy_position)-1
	return round(distScore + ballScore) * eposScore * 0.75 

func calculateFleePriority(distance, enemy_position, balloons):
	var distScore = 320.0 * pow(4, -log(distance / 320.0))
	var ballScore = pow(10,4-balloons)
	var eposScore = 1-enemy_position #pow(2,1-enemy_position)-1
	return round(distScore + ballScore) * eposScore

func calculateAttackPriority(distance, enemy_position, balloons):
	var distScore = 640.0 * pow(2, -log(distance / 640.0))
	var ballScore = pow(14,balloons/1.05)
	var eposScore = 1.25+enemy_position #pow(2,1-enemy_position)-1
	return round(distScore + ballScore) * eposScore

func calculateAvoidPriority(distance, enemy_position, balloons):
	if distance > 128: return 1
	var distScore = 128.0 * pow(40, -log(distance / 128.0))
	var ballScore = pow(10,4-balloons)
	return round(distScore + ballScore) / 2

func verticalAngle(c1,c2):
	return (c1.position - c2.position).normalized().dot(Vector2.UP)
	
func distanceBetween(c1,c2):
	return c1.get_global_position().distance_to(c2.get_global_position())

func distanceBetweenPoint(c1,c2):
	return c1.distance_to(c2)
	
func verticalAnglePoints(c1,c2):
	return (c1 - c2).normalized().dot(Vector2.UP)
	
func updateFleeTarget ():
	
	var newTarget = [
		getEscapeRouteQuality(character1,character1.position+Vector2(128,0)),
		getEscapeRouteQuality(character1,character1.position+Vector2(-128,0)),
		getEscapeRouteQuality(character1,character1.position+Vector2(0,-128)),
		getEscapeRouteQuality(character1,character1.position+Vector2(0,128)),
		getEscapeRouteQuality(character1,character1.position+Vector2(128,128)),
		getEscapeRouteQuality(character1,character1.position+Vector2(-128,-128)),
		getEscapeRouteQuality(character1,character1.position+Vector2(-128,128)),
		getEscapeRouteQuality(character1,character1.position+Vector2(128,-128)),
	]
	#print("neewyt",newTarget)
	#newTarget = newTarget.reduce(func(a,b):return b if b.score>a.score else a,{score=-1})
	#character2.point = newTarget.position
	#character2.direction = character1.to_local(newTarget.position).normalized()

func getEscapeRouteQuality(character, position:Vector2):
	var closestPositionOnLine = getClosestPositionOnLine(character.position,position,character2.position)
	var distanceOfClosestPositionOnLine = distanceBetweenPoint(character.position, closestPositionOnLine)
	
	var score = 0
	#var score = position.distance_to(character2.position)
	score += closestPositionOnLine.distance_to(character2.position)
	if character.position.distance_to(character2.position) > 32:
		score += verticalAnglePoints(character2.position,position)*-24
	#if position.y < 16 or position.y > 360-16: score -= 32
	#if position.x < 16 or position.x > 640-16: score -= 32
	#score = score * max(0.0, 1.0 - (max(0, position.x - 32, 640 - position.x - 32, position.y - 32, 360 - position.y - 32) - 32) / 96)
	if position.x < 32: score = score * ((128-abs(position.x - 32))/128)
	if position.x > 640-32: score = score * ((128-abs(640-32 - position.x))/128)
	if position.y < 32: score = score * ((128-abs(position.y - 32))/128)
	if position.y > 360-32: score = score * ((128-abs(360-32 - position.y))/128)
		
	

	
	score = max(0,round(score))
	draw_line(character.position,position,Color.DARK_BLUE,2) 
	draw_circle(closestPositionOnLine,5,Color.YELLOW.lerp(Color.RED,score/500))
	draw_circle(position,score/16+8,Color.YELLOW.lerp(Color.RED,score/500))
	draw_string(default_font, position-Vector2(5,0),str(score), HORIZONTAL_ALIGNMENT_CENTER, -1, 8,  Color.BLACK  )
	
	return {
		score =  score,
		position = position
	}

func getClosestPositionOnLine(l1,l2,targetPos):
	var line_direction = (l2 - l1).normalized()
	var vector_to_object = targetPos - l1
	var distance = line_direction.dot(vector_to_object)
	var distance_along_line = max(32, min(distance, (l2 - l1).length()))
	var closest_position = l1 + distance_along_line * line_direction
	return closest_position
