extends Area3D

func _on_body_entered(body: Node3D) -> void:
	# On vérifie si l'objet qui entre (le player) possède la variable 'soul'
	if "soul" in body:
		# 1. On incrémente la variable au singulier
		body.soul += 1
		
		# 2. On lance ta fonction switch_flame
		if body.has_method("switch_flame"):
			body.switch_flame()
		
		# 3. On supprime la soul de la scène
		queue_free()
