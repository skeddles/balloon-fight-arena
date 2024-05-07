extends Node

func getNewFleeTarget (character, escapeFromPoint):
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
