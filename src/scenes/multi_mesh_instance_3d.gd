@tool
extends MultiMeshInstance3D

@export var source_mesh: MeshInstance3D  # Votre sol
@export var grass_count: int = 10000      # Nombre max de tentatives
@export var green_threshold: float = 0.5  # Seuil de détection du vert

func _ready():
	generate_grass()

func generate_grass():
	if not source_mesh or not multimesh:
		return

	var mesh = source_mesh.mesh
	var material = source_mesh.get_active_material(0) as StandardMaterial3D
	
	if not material or not material.albedo_texture:
		push_error("Le sol doit avoir un StandardMaterial3D avec une texture Albedo.")
		return

	# Préparer l'accès aux données de l'image
	var image = material.albedo_texture.get_image()
	var img_size = image.get_size()
	
	# UtiliserMeshDataTool pour obtenir les faces (plus complexe mais précis)
	# Pour faire simple ici, on utilise l'AABB (la boîte englobante)
	var aabb = mesh.get_aabb()
	var valid_instances = []

	for i in range(grass_count):
		# 1. Choisir une position aléatoire sur le plan XZ
		var pos = Vector3(
			randf_range(aabb.position.x, aabb.end.x),
			0,
			randf_range(aabb.position.z, aabb.end.z)
		)
		
		# 2. Convertir la position 3D en coordonnées UV (simplifié pour un plan)
		var uv_x = remap(pos.x, aabb.position.x, aabb.end.x, 0, 1)
		var uv_z = remap(pos.z, aabb.position.z, aabb.end.z, 0, 1)
		
		# 3. Lire la couleur du pixel
		var pixel_x = clampi(uv_x * img_size.x, 0, img_size.x - 1)
		var pixel_y = clampi(uv_z * img_size.y, 0, img_size.y - 1)
		var color = image.get_pixel(pixel_x, pixel_y)

		# 4. Vérifier si c'est assez "vert"
		if color.g > color.r and color.g > green_threshold:
			var transform = Transform3D()
			# Aligner avec le sol (Y) et rotation aléatoire pour le réalisme
			transform = transform.rotated(Vector3.UP, randf_range(0, TAU))
			transform.origin = pos + source_mesh.global_position
			valid_instances.append(transform)

	# 5. Appliquer au MultiMesh
	multimesh.instance_count = valid_instances.size()
	for i in range(valid_instances.size()):
		multimesh.set_instance_transform(i, valid_instances[i])

	print("Herbe générée : ", valid_instances.size(), " brins.")
