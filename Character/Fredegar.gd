extends KinematicBody2D
class_name Player

enum {
	MOVE,
	CLIMB,
	ATTACK,
	
}

export(Resource) var moveData = preload("res://Character/DefaultPlayerMovement.tres") as PlayerMovement

const StoneProjectile = preload("res://Character/Projectile/Projectile.tscn")

onready var animatedSprite: = $AnimatedSprite
onready var ladderCheck: = $LadderCheck
onready var jumpBufferTimer: = $JumpBufferTimer
onready var coyoteJumpTimer: = $CoyoteJumpTimer
onready var remoteTransform: = $RemoteTransform2D
onready var heldStonePosition: = $HeldStonePosition

var held_stone = null




var velocity = Vector2.ZERO
var state = MOVE
var double_jump = 1
var buffered_jump = false
var coyote_jump = false

func _physics_process(delta):
	var input = Vector2.ZERO	
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: move_state(input, delta)
		CLIMB: climb_state(input)
		ATTACK: attack_state(input)
		



func move_state(input, delta):
	if is_on_ladder() and Input.is_action_just_pressed("ui_up"):
		state = CLIMB
		animatedSprite.animation = "Climb"
		
			
		
	apply_gravity(delta)
	if not horizontal_movement(input):
		apply_friction(delta)
		animatedSprite.animation = "Idle"
	else:
		apply_accelaration(input.x, delta)
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = input.x < 0 
	
	if is_on_floor():
		reset_double_jump()
	else:
		animatedSprite.animation = "Jump"
	
	if can_jump():
		input_jump()		
	else:
		input_jump_release()
		
		input_double_jump()
			
		buffer_jump()
			
		fast_fall(delta)
	
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()					 
	velocity = move_and_slide(velocity, Vector2.UP)
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		SoundPlayer.play_sound(SoundPlayer.LAND)
		animatedSprite.animation = "Fall"	 
		animatedSprite.frame = 1
		$Dust.position.x = Vector2.AXIS_X
		if animatedSprite.flip_h:
			$Dust.emitting = true
			$Dust.position.x = $Dust.position.x + 10
			
		else:	
			$Dust.emitting = true
			$Dust.position.x = $Dust.position.x - 10
	
	
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y >=0:
		coyote_jump = true
		coyoteJumpTimer.start()
	
func climb_state(input):
	if not is_on_ladder(): state = MOVE
	if input.length() != 0:
		animatedSprite.animation = "Climb"
		animatedSprite.flip_h = false
		
	else:
		animatedSprite.animation = "ClimbStoped"
	velocity = input * moveData.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)
	
func attack_state(input):
	if not is_on_ladder() and Input.is_action_pressed("ui_accept"):
		_on_AnimatedSprite_animation_finished()
		animatedSprite.animation("Attack")

func player_die():
	SoundPlayer.play_sound(SoundPlayer.HURT)
	queue_free()
	Events.emit_signal("player_died")
	
func connect_camera(camera):
	var camera_path = camera.get_path()
	remoteTransform.remote_path = camera_path
	

func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true

func apply_gravity(delta):
	velocity.y += moveData.GRAVITY * delta
	velocity.y = min(velocity.y, 300)
	
func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION * delta)
	
func apply_accelaration(amount, delta):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION * delta)
			
func input_jump():
	if Input.is_action_just_pressed("ui_up") or buffered_jump == true:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.JUMP_FORCE
		buffered_jump = false

func reset_double_jump():
	double_jump = moveData.DOUBLE_JUMPS_COUNT

func can_jump():
	return is_on_floor() or coyote_jump == true
	
func input_jump_release():
	if Input.is_action_just_released("ui_up") and velocity.y < moveData.JUMP_RELEASE_FORCE:
		velocity.y = moveData.JUMP_RELEASE_FORCE
	
func input_double_jump():
	if Input.is_action_just_pressed("ui_up") and double_jump > 0:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.JUMP_FORCE
		double_jump -= 1
	
func buffer_jump():
	if Input.is_action_just_pressed("ui_up"):
		buffered_jump = true
		jumpBufferTimer.start()
	
func fast_fall(delta):
	if velocity.y > 0:
		velocity.y += moveData.ADITIONAL_GRAVITY_FALL * delta
		animatedSprite.animation = "Fall"			
	
func horizontal_movement(input):
	return input.x != 0
	
func _on_JumpBufferTimer_timeout():
	buffered_jump = false
	
func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false

func spawn_rock():
	if held_stone == null:
		held_stone = StoneProjectile.instance()
		heldStonePosition.add_child(held_stone)

func _on_AnimatedSprite_animation_finished():
	#held_stone.launch()
	held_stone = null
