extends CharacterBody2D

@export var speed = 0
@export var direction:Vector2 = Vector2.ZERO

func _physics_process(delta):
	var velocity = delta * speed * direction
	var collision = move_and_collide(velocity)
	if collision:
		print("colly")
		direction = direction.bounce(collision.get_normal())
		
