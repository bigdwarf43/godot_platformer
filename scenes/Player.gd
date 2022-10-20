extends KinematicBody2D


const ACCELERATION = 200
const BOUNCE_VELOCITY = -(10 * Globals.UNIT_SIZE)

onready var bounce_raycasts = $BounceRaycast


var move_speed = 100
var gravity = 400.0
var max_jump_speed
var min_jump_speed
var max_jump_height = 1.5 * Globals.UNIT_SIZE
var min_jump_height = 0.5 * Globals.UNIT_SIZE
var jump_duration = 0.5 
var can_jump = true
var jump_was_pressed = false

#for dash
var can_dash = true
var is_dashing = false
var dash_speed = 300


var move_dir = 0
var velocity = Vector2()

func _ready():
	gravity = 2 * max_jump_height/ pow(jump_duration, 2)
	max_jump_speed = -sqrt(2 * gravity * max_jump_height)
	min_jump_speed = -sqrt(2 * gravity * min_jump_height)

func _physics_process(delta):
	
	var friction = false
	velocity.y += delta * gravity
	
	if Input.is_action_pressed("move_left"):
		velocity.x = max(velocity.x-ACCELERATION, -move_speed)
		$Sprite.flip_h = true
	elif Input.is_action_pressed("move_right"):
		velocity.x = min(velocity.x+ACCELERATION, move_speed)
		$Sprite.flip_h = false

	else:

		friction = true
	
	if Input.is_action_just_pressed("dash"):
		if can_dash == true and !velocity.x == 0:
			dash()
			$sound_dash.play()
			can_dash = false
			$dash_timer.start()
	
	_check_bounce(delta)
	var was_on_floor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_floor():
		can_jump = true
		if jump_was_pressed == true:
			velocity.y = max_jump_speed
			
		if friction == true:
			velocity.x = lerp(velocity.x, 0, 0.2)
		
	"""
	
	ADD JUMP CODE HERE
	JUMP INPUT KEY IS ALREADY SET
	
	
	"""
		
			
	if Input.is_action_just_released("jump") && velocity.y < min_jump_speed:
		velocity.y = min_jump_speed
		
	if !is_on_floor():
		coyote_time()
		if friction == true:
			velocity.x = lerp(velocity.x, 0, 0.05)
	
	if velocity.y > 700:
		die()
			


func _check_bounce(delta):
	if velocity.y > 0:
		for raycast in bounce_raycasts.get_children():
			raycast.cast_to = Vector2.DOWN * velocity * delta + Vector2.DOWN
			raycast.force_raycast_update()
			if raycast.is_colliding() && raycast.get_collision_normal() == Vector2.UP:
				velocity.y = (raycast.get_collision_point() - raycast.global_position - Vector2.DOWN).y / delta
				raycast.get_collider().entity.call_deferred("be_bounced_upon", self)
				break

func bounce(bounce_velocity = BOUNCE_VELOCITY ):
	velocity.y = bounce_velocity
	
func coyote_time():
	yield(get_tree().create_timer(.1),"timeout")
	can_jump = false
	
func remember_jump_time():
	yield(get_tree().create_timer(.1),"timeout")
	jump_was_pressed = false
	
func dash():
	is_dashing = true 
	move_speed = dash_speed
	gravity = 0
	$dash_timer.start()

func _on_gap_timer_timeout():
	can_dash = true

func _on_dash_timer_timeout():
	is_dashing = false	
	gravity = 2 * max_jump_height/ pow(jump_duration, 2)
	move_speed = 100


# for the dash effect
func _on_ghost_timer_timeout():
	if is_dashing == true:
		#make a copy of ghst object 
		var this_ghost = preload("res://scenes/ghost.tscn").instance()
		#assign ghost a parent ie the player node
		get_parent().add_child(this_ghost)
		this_ghost.position = position
		this_ghost.texture = $Sprite.frames.get_frame($Sprite.animation, $Sprite.frame)
		this_ghost.flip_h = $Sprite.flip_h

func touched_enemy(enemyposx):
	set_modulate(Color(4, 0.3, 0.3, 0.8))
	bounce(-7*Globals.UNIT_SIZE)
	
	if position.x < enemyposx:
		velocity.x = -400
	elif position.x > enemyposx:
		velocity.x = 400
	Input.action_release("move_left")
	Input.action_release("move_right")
	$reset_timer.start()

func _on_reset_timer_timeout():
	die()
	
func die():
	$TransitionScreen.transition()

func _on_TransitionScreen_transitioned():
	get_tree().reload_current_scene()
