extends Area2D


func _on_zoomCamera_body_entered(body):
	print("entrou")
	if body.name == "Fredegar" and body.has_method("zoomIn"):
		body.zoomIn() 


func _on_zoomCamera_body_exited(body):
	pass
