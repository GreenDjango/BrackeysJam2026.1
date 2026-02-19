extends Area3D # Ou le nœud où se trouve ton script

func _process(delta):
	# 1. Calcul de la valeur aléatoire entre 19 et 20
	var noise_val = randf_range(19.0, 20.0)
	
	# 2. Accès au MeshInstance3D
	var mesh_node = $MeshInstance3D
	
	# 3. Récupération du matériau actif sur le premier slot (index 0)
	var mat = mesh_node.get_active_material(0)
	
	# 4. Vérification de sécurité et application
	if mat:
		mat.set_shader_parameter("Noise_size", noise_val)
