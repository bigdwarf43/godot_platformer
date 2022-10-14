extends KinematicBody2D

var walk_speed= 25
var gravity = 10.0
var velocity = Vector2()
var move_dir = -1
var facing_left = true

func _physics_process(delta):
	velocity.y += gravity
	
	velocity.x = walk_speed * move_dir
	move_and_slide(velocity,Vector2(0,-1))
	
	if is_on_wall():
		move_dir = -move_dir
		$RayCast2D.position.x *= -1
		
	if $RayCast2D.is_colliding() == false:
		move_dir = - move_dir
		$RayCast2D.position.x *= -1
		
	if facing_left and move_dir > 0:
		flip()
	if !facing_left and move_dir < 0:
		flip()
	
	
		
func flip():
	facing_left = !facing_left
	$Sprite.flip_h = !$Sprite.flip_h


func _on_StompArea2D_body_entered(body):
	body.bounce(-7*Globals.UNIT_SIZE)
	$Sprite.play("squashed")
	$sound_squash.play()
	$Timer.start()

func _on_SidesChecker_body_entered(body):
	if body.has_method("touched_enemy"):
		$sound_hurt.play()
		body.touched_enemy(position.x)

func _on_Timer_timeout():
	queue_free()
