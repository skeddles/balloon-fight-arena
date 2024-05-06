@tool
extends EditorScript
const Priority = preload("res://scripts/priority.gd")
################ priority.gd

enum {IDLE,CHASE,FLEE,FILL,AVOID}

func calculateRefillPriority(distance, enemy_position, balloons):
	var distScore = 640.0 * pow(2, log(distance / 640.0))
	var ballScore = pow(12,4-balloons)
	var eposScore = (1-enemy_position)*0.75 #pow(2,1-enemy_position)-1
	return round(distScore + ballScore) * eposScore * 0.75 

func calculateFleePriority(distance, enemy_position, balloons):
	var distScore = 640.0 * pow(2, -log(distance / 640.0))
	var ballScore = pow(10,4-balloons)
	var eposScore = 1-enemy_position #pow(2,1-enemy_position)-1
	return round(distScore + ballScore) * eposScore

func calculateAttackPriority(distance, enemy_position, balloons):
	var distScore = 640.0 * pow(2, -log(distance / 640.0))
	var ballScore = pow(10,balloons/1.25)
	var eposScore = 1+enemy_position #pow(2,1-enemy_position)-1
	return round(distScore + ballScore) * eposScore / 3
	
func calculateAvoidPriority(distance, enemy_position, balloons):
	var distScore = 640.0 * pow(2, -log(distance / 640.0))
	var ballScore = pow(10,4-balloons)
	return round(distScore + ballScore)
	
	
##################################

func _run():
	var pr = self
	print("\n\n\nPriority Test:")
	
	var priorities = []
	
	var position = {
		above = -1,
		diagAbove = -0.5,
		side = 0.5,
		diagBelow = 0.5,
		below = 1,
	}
	
	for distance in [8,16,32,64,128,256,512,640]:
		for enemy_position in ["above","diagAbove","side","diagBelow","below"]:
			for balloons in [0,1,2,3,4]: #temp took out 0 since its a  special case
				var inputString = str("distance:"+str(distance)+"px \t| enemyPos:"+str(enemy_position)+" \t| balloons x"+str(balloons))   
				#flee
				var fleeScore = pr.calculateFleePriority(distance,position[enemy_position],balloons)
				priorities.append([fleeScore,"FLEE: "+str(fleeScore)+" \t| "+inputString])
				#avoid
				var avoidScore = pr.calculateAvoidPriority(distance,position[enemy_position],balloons)
				priorities.append([avoidScore,"AVOID: "+str(avoidScore)+" \t| "+inputString])
				#attack
				var attackScore = pr.calculateAttackPriority(distance,position[enemy_position],balloons)
				priorities.append([attackScore,"ATTACK: "+str(attackScore)+" \t| "+inputString])
				#refill
				var refillScore = pr.calculateRefillPriority(distance,position[enemy_position],balloons)
				priorities.append([refillScore,"REFILL: "+str(refillScore)+" \t| "+inputString])
	
	priorities.sort_custom(func(a,b): 
		return b[0] < a[0]
	)
	
	var i = 1;
	for p in priorities:
		print (i," ",p[1])
		i+=1
	
	var newTarget = [{score=4},{score=2}]
	newTarget = newTarget.reduce(func(a,b):
		return b if b.score>a.score else a,
		{score=0}
	)
	
	print (newTarget)
