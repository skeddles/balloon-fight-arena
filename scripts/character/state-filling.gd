extends CharacterState

var Character
var current_fill_amount = 0

func _init(character): 
	Character = character

func start():
	current_fill_amount = 0

func process(delta, _input):

	# Balloon Filling
	var filling=false
	if $Sprite.animation == 'refill': filling = true
	if input.fill and is_on_floor() and velocity.x < 5:
		if $Sprite.animation != 'refill' or !$Sprite.is_playing():
			if stored_balloons > 0 and current_balloons < 4:
				current_fill_amount+=1
				filling = true
				$Audio/Fill.play()
				$Sprite.play("refill")
				if current_fill_amount>2: $BalloonFilling.play("fill_2")
				else: $BalloonFilling.play("fill_1")
			else: # TODO play nono sound effect
				pass
	if input.dirAxis or input.jumped:
		current_fill_amount = 0
		filling=false
		$BalloonFilling.play("blank")
		
	if is_on_floor():
		if filling: $Sprite.animation = 'refill'

func _on_jump():
	Character.switch_state("normal")._on_jump()

func _on_move():
	Character.switch_state("normal")._on_move()

func _on_attack():
	Character.switch_state("normal")._on_attack()

func _on_sprite_animation_finished():
	if $Sprite.animation == 'refill':
		if stored_balloons > 0 and current_fill_amount>=4:
			current_fill_amount = 0
			stored_balloons -= 1
			current_balloons += 1
			playerHUD.update()
			switchCollisionShape()
			$BalloonFilling.play("blank")
			$Balloons.animation = str(current_balloons) + "_idle"
			$Audio/Filled.play()
