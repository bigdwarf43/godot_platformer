extends Node2D

func be_bounced_upon(bouncer):
	$Sprite.play("idle_shroom")
	if bouncer.has_method("bounce"):
		bouncer.bounce()
		$Sprite.play("bounce")	
		$sound_bounce.play()
		

		

	
