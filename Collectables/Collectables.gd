extends Area2D




func _on_Collectables_body_entered(body):
	$AnimationPlayer.play("collected")
	SoundPlayer.play_sound(SoundPlayer.COLLECTABLES)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "collected":
		queue_free()
