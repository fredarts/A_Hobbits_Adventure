extends Area2D

onready var animatedSprite: = $AnimatedSprite
onready var savepoint_sfx: = $AudioStreamPlayer

var active = true

func _on_SavePoint_body_entered(body):
	if not body is Player: return
	if not active: return
	animatedSprite.play("Cheked")
	savepoint_sfx.play()
	active = false
	Events.emit_signal("hit_savepoint", position)
