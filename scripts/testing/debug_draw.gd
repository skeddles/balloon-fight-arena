extends Node2D

var rects = []

func _process(_delta):
	queue_redraw()


func _draw():
	for r in rects:
		draw_rect(r[0], r[1])
