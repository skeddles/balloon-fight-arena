extends Node2D

var number_string = preload("res://scripts/util/format-number-string.gd").new()

var DEBUG = true
const MAX_SCROLL_SPEED = 50.0
const OBSTACLE_SPACING = [1,10,25,50,75,100,150,200,250,300,350,400,500,750,1000,2500]
const SPEED_TIERS = [100,50,25]

@onready var Character = $Character
@onready var LastObstacle = $Obstacles/middle

var ObstaclePatterns = {}
var rng = RandomNumberGenerator.new()
var obstaclesAdded = 0

func _ready():
	Character.current_balloons = 2
	Character.playerHUD = self
	Character.init()
	
	# attach controller
	var controller = preload("res://scenes/controls/human.tscn").instantiate()
	controller.InputScheme = "singleplayer"
	Character.add_child(controller)
	Character.controller = controller

	# load obstacle patterns
	for level in Array(DirAccess.get_directories_at("res://scenes/trip/")):
		print("loading ",level)
		ObstaclePatterns[level] = []
		for pattern in Array(DirAccess.get_files_at("res://scenes/trip/"+level)):
			print("  loading pattern ", pattern)
			ObstaclePatterns[level].append(pattern.replace('.remap', ''))
			
	$Sounds/Music.play()

func _process(delta):
	if not is_instance_valid(Character): return 
	
	
	var score = current_distance()
	$Camera.position.x -= delta * get_scroll_speed(score)
	$GUI/Panel/Distance/Score.text = number_string.format(score)
	$GUI/Panel/Distance/Trophy/Sprite.region_rect = Rect2(16*$GUI/HighScoreList.get_trophy_level(score),0,16,16)

	if LastObstacle.position.x > $Camera.position.x:
		print("spawning next obstacle")
		spawnNewObstacle()
		removeOldObstacles()
	
	if abs($TileMap.position.x - $Camera.position.x) > 640:
		$TileMap.position.x -= 640
	
	queue_redraw()

const START_SCROLL_SPEED = 25
func get_scroll_speed(score):
	if score > 100: return MAX_SCROLL_SPEED
	var factor = score / 100.0
	return (1 - factor) * START_SCROLL_SPEED + factor * MAX_SCROLL_SPEED

func current_distance(): return round(abs($StartingPlatform.position.x-Character.position.x)/8)

func spawnNewObstacle():
	var newObstaclePattern = chooseNewObstaclePattern()
	print("picked new obstacle: ",newObstaclePattern)
	var newObstacle = load("res://scenes/trip/level-"+newObstaclePattern).instantiate()
	newObstacle.position.x = LastObstacle.position.x - newObstacle.size.x - (get_obstacle_spacing()*8)
	newObstacle.position.y = LastObstacle.position.y
	newObstacle.editor_only = !DEBUG
	if rng.randf() > 0.5: flipObstacleVertically(newObstacle)
	
	$Obstacles.add_child(newObstacle)
	LastObstacle = newObstacle
	
	obstaclesAdded += 1
	newObstacle.path = newObstaclePattern.replace(".tscn", "")
	newObstacle.number = obstaclesAdded

func get_obstacle_spacing():
	var score = current_distance()
	var level = 16
	for g in OBSTACLE_SPACING: 
		if g > score: break
		level-=1
	return level

func flipObstacleVertically(obstacle):
	for spark in obstacle.get_children():
		spark.position.y = obstacle.size.y - spark.position.y
		spark.direction.y = spark.direction.y*-1

func chooseNewObstaclePattern():
	var dist = current_distance()
	var pattern_level
	
	if dist > 1000 and rng.randf() > 0.75: pattern_level = 4
	if dist > 500 and rng.randf() > 0.75: pattern_level = 3
	elif dist > 250 and rng.randf() > 0.75: pattern_level = 2
	elif dist > 100 and rng.randf() > 0.75: pattern_level = 1
	else: pattern_level = 0
	# rng.randf() > 500/dist
	
	var pattern = ObstaclePatterns["level-"+str(pattern_level)].pick_random()
	return str(pattern_level)+"/"+pattern

func removeOldObstacles():
	for o in $Obstacles.get_children():
		if o.position.x > $Camera.position.x + 640:
			print("removing old obstacle")
			o.queue_free()

func update():
	print("update")

func _draw():
	if !DEBUG: return
	for o in $Obstacles.get_children():
		var Yoffset = 30 + (o.number % 3) * 10
		draw_string(ThemeDB.fallback_font, Vector2(o.position.x+1, Yoffset), o.path, 0, 0, 8)
	
	draw_string(ThemeDB.fallback_font, Vector2( $Camera.position.x+5, 320),"speed:"+str(get_scroll_speed(current_distance())), 0, 0, 8)	
	draw_string(ThemeDB.fallback_font, Vector2( $Camera.position.x+5, 330),"spacing:"+str(get_obstacle_spacing()), 0, 0, 8)

	

func _game_over():
	$Sounds/Music.stop()
	$Sounds/End.play()
	$GUI/HighScoreList.update_and_reveal_high_scores(current_distance())

func _input(event):
	if Input.is_action_just_pressed("debug"): 
		DEBUG = true
		print("debug toggled")
