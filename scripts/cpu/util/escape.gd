extends Node

const ESCAPE_POINT_COUNT = 16
const ESCAPE_RADIUS = 96


func getNewFleeTarget (character, escapeFromPoint):
	if not character: return
	var possibleTargets = getPossibleTargets()
	possibleTargets = possibleTargets.map(func(t): return getEscapeRouteQuality(character,character.position+t, escapeFromPoint))
	var newTarget = possibleTargets.reduce(func(a,b):return b if b.score>a.score else a,{score=-1})
	character.get_node("NavigationAgent2D").target_position = newTarget.position
	var fleeTargetPoint = character.get_node("NavigationAgent2D").get_next_path_position() + Vector2(0,-10)
	var fleeTargetDirection = character.to_local(character.get_node("NavigationAgent2D").get_next_path_position()).normalized()
	return [fleeTargetPoint,fleeTargetDirection]

func getEscapeRouteQuality(character, escapeLocationOptionPoint:Vector2, escapeFromPoint:Vector2):
	var closestPositionOnLine = getClosestPositionOnLine(character.position,escapeLocationOptionPoint,escapeFromPoint)
	var distanceOfClosestPositionOnLine = character.position.distance_to(closestPositionOnLine)
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

func getPossibleTargets():
	var possibleTargets = []
	for i in range(ESCAPE_POINT_COUNT):
		var angle = (i / ESCAPE_POINT_COUNT) * 2.0 * PI
		var x = cos(angle) * ESCAPE_RADIUS
		var y = sin(angle) * ESCAPE_RADIUS
		var pointOffset = Vector2(x,y)
		possibleTargets.append(pointOffset)
	return possibleTargets
