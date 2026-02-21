@tool # Pour voir le résultat directement dans l'éditeur
extends MultiMeshInstance3D

@export var instance_count: int = 500
@export var area_size: Vector2 = Vector2(50, 50)
@export var terrain_node: Node3D # Glisse ton sol (StaticBody3D) ici

func _ready():
	generate_grass()

func generate_grass():
	if not multimesh: return
	
	multimesh.instance_count = 0 # Reset pour éviter les erreurs
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = instance_count
	
	# Accès au monde physique pour lancer les rayons
	var space_state = get_world_3d().direct_space_state
	
	for i in range(instance_count):
		# 1. Choisir une position X et Z aléatoire
		var x = randf_range(-area_size.x / 2, area_size.x / 2)
		var z = randf_range(-area_size.y / 2, area_size.y / 2)
		
		# 2. Lancer un rayon du haut vers le bas
		var origin = global_position + Vector3(x, 20, z) # Part de 20m de haut
		var end = global_position + Vector3(x, -20, z)   # Jusqu'à 20m en bas
		
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		var result = space_state.intersect_ray(query)
		
		if result:
			# 3. Si le rayon touche le sol, on récupère la position précise
			var pos = to_local(result.position)
			
			# 4. Créer la rotation et l'échelle aléatoire pour le réalisme
			var basis = Basis().rotated(Vector3.UP, randf_range(0, PI * 2))
			basis = basis.scaled(Vector3.ONE * randf_range(0.8, 1.2)) # Taille variée
			
			var xform = Transform3D(basis, pos)
			multimesh.set_instance_transform(i, xform)
		else:
			# Si on ne touche pas le sol, on cache l'instance sous la map
			multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(0, -100, 0)))
