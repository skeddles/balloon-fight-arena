extends Node2D

var bolt:AnimatedSprite2D
var rng = RandomNumberGenerator.new()
var spark = preload("res://scenes/spark.tscn")

func _ready():
	$Bolt_NE.visible = false
	$Bolt_NW.visible = false
	$Bolt_SE.visible = false
	$Bolt_SW.visible = false
	
	$Sprite.play("appear")
	
func done_appearing():
	$Sprite.play("idle")
	await get_tree().create_timer(rng.randf_range(2.0,10.0)).timeout
	start_lightning()

func start_lightning():
	$Sprite.play("flashing")
	await get_tree().create_timer(1).timeout
	$Sprite.play("idle")
	
	bolt = get_node("Bolt_"+ ['NW','NE','SE','SW'].pick_random())
	bolt.visible = true
	bolt.play()
	$Sounds/Lightning.play()
	
	await get_tree().create_timer(rng.randf_range(15.0,30.0)).timeout
	start_lightning()

func _on_sprite_animation_finished():
	if $Sprite.animation == "appear": done_appearing()

func _on_bolt_sprite_animation_finished(direction):
	print(bolt.name, direction)
	bolt.visible = false
	var newSpark = spark.instantiate()
	newSpark.position = bolt.position
	newSpark.direction = direction
	newSpark.speed = rng.randf_range(50.0,100.0)
	add_child(newSpark)
	pass
	
