@tool
extends Node2D

var Escape = preload("res://scripts/cpu/util/escape.gd").new()

var StateIdle = preload("res://scripts/cpu/state-idle.gd").new()
var StateFlee = preload("res://scripts/cpu/state-flee.gd").new()
var StateAttack = preload("res://scripts/cpu/state-attack.gd").new()
var StateFill = preload("res://scripts/cpu/state-fill.gd").new()
var StateAvoid = preload("res://scripts/cpu/state-avoid.gd").new()

@export var character1:Sprite2D
@export var character2:Sprite2D
@export var balloon_count:int = 2
@onready var default_font = ThemeDB.fallback_font

const hazardTileLocation = Vector2(20,32)*8.0

func _draw():
	#draw_line(Vector2.ZERO,Vector2(20,20),Color.RED,1.0)
	drawData(character1)
	#drawData(character2)
	pass

func drawData(character):
	var data = character.name

	#draw_string(default_font, character.position+Vector2(-50, 15+10*0), str(character.name), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
	#draw_string(default_font, character.position+Vector2(-50, 15+10*1), str(character.position), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE)
	
	for et in Escape.getPossibleTargets():
		var charpos = character.position
		var quality = Escape.getEscapeRouteQuality(character, charpos-et, hazardTileLocation)
		var score = round(quality.score)
		draw_circle(charpos-et, 8+score/20, Color.YELLOW.lerp(Color.RED, score/300))
		draw_string(default_font, charpos-et,str(score), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.WHITE  )
	
	var avd = round(StateAvoid.calculatePriority(distanceBetweenPoint(character1.position, Vector2(20*8,32*8)), balloon_count, 100))
	var atk = round(StateAttack.calculatePriority(distanceBetween(character1,character2), verticalAngle(character1,character2), balloon_count))
	var flee = round(StateFlee.calculatePriority(distanceBetween(character1,character2), verticalAngle(character1,character2), balloon_count))
	var fil = round(StateFill.calculatePriority(distanceBetween(character1,character2), verticalAngle(character1,character2), balloon_count))

	var highest = max(avd, atk, flee, fil)

	draw_string(default_font, character.position+Vector2(-50, 15+10*2)," attack: "+str(atk), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color.RED if atk==highest else Color.WHITE  )
	draw_string(default_font, character.position+Vector2(-50, 15+10*3)," flee: "+str(flee), HORIZONTAL_ALIGNMENT_CENTER, -1, 8,  Color.RED if flee==highest else Color.WHITE  )
	draw_string(default_font, character.position+Vector2(-50, 15+10*4)," avoid: "+str(avd), HORIZONTAL_ALIGNMENT_CENTER, -1, 8,  Color.RED if avd==highest else Color.WHITE  )
	draw_string(default_font, character.position+Vector2(-50, 15+10*5)," fill: "+str(fil), HORIZONTAL_ALIGNMENT_CENTER, -1, 8,  Color.RED if fil==highest else Color.WHITE  )
	
func _process(delta):
	queue_redraw()

func verticalAngle(c1,c2):
	return (c1.position - c2.position).normalized().dot(Vector2.UP)
	
func distanceBetween(c1,c2):
	return c1.get_global_position().distance_to(c2.get_global_position())

func distanceBetweenPoint(c1,c2):
	return c1.distance_to(c2)

func getClosestPositionOnLine(l1,l2,targetPos):
	var line_direction = (l2 - l1).normalized()
	var vector_to_object = targetPos - l1
	var distance = line_direction.dot(vector_to_object)
	var distance_along_line = max(32, min(distance, (l2 - l1).length()))
	var closest_position = l1 + distance_along_line * line_direction
	return closest_position
