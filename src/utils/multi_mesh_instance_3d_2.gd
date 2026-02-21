@tool
extends MultiMeshInstance3D

@export_group("Paramètres de Placement")
@export var instance_count: int = 3000
@export var target_surface: StaticBody3D
@export var terrain_texture: Texture2D 
@export var area_size: float = 1000.0
@export var placement_seed: int = 42 

@export_group("Collision")
@export var collision_shape: Shape3D 
# On laisse l'offset au cas où, mais le code va essayer de le deviner
@export var manual_height_offset: float = 0.0 

@export_group("Randomisation")
@export var scale_min: float = 0.8
@export var scale_max: float = 1.5

@export_group("Contraintes")
@export var max_height: float = 100.0
@export var max_slope_degrees: float = 15.0
@export var green_threshold: float = 0.1

@export_group("")
@export_tool_button("Generer maintenant")
@warning_ignore("unused_private_class_variable")
var _generer_maintenant = prepare_and_run

var terrain_image: Image
var noise: FastNoiseLite

func prepare_and_run():
	if terrain_texture:
		terrain_image = terrain_texture.get_image()
		if terrain_image.is_compressed(): terrain_image.decompress()
	place_instances()

func place_instances():
	if multimesh == null or terrain_image == null: return

	if noise == null: noise = FastNoiseLite.new()
	noise.seed = placement_seed
	noise.frequency = 0.05
	
	seed(placement_seed)
	multimesh.instance_count = instance_count
	
	var space_state = get_world_3d().direct_space_state
	var count_placed = 0
	#var slope_threshold = cos(deg_to_rad(max_slope_degrees))
	
	for i in range(instance_count):
		var x = randf_range(-area_size / 2, area_size / 2)
		var z = randf_range(-area_size / 2, area_size / 2)
		
		if noise.get_noise_2d(x, z) < 0.1: continue
		
		var origin = global_position + Vector3(x, 200, z)
		var query = PhysicsRayQueryParameters3D.create(origin, origin + Vector3(0, -400, 0))
		query.exclude = [self]
		var result = space_state.intersect_ray(query)

		if result:
			if target_surface and result.collider != target_surface: continue
			
			var uv_x = (x / area_size) + 0.5
			var uv_z = (z / area_size) + 0.5
			var px = clamp(uv_x * terrain_image.get_width(), 0, terrain_image.get_width() - 1)
			var py = clamp(uv_z * terrain_image.get_height(), 0, terrain_image.get_height() - 1)
			
			if terrain_image.get_pixel(px, py).g > terrain_image.get_pixel(px, py).r + green_threshold:
				var rot_y = randf_range(0, TAU)
				var s = randf_range(scale_min, scale_max)
				
				# Basis gère la rotation et le scale
				var b = Basis(Vector3.UP, rot_y).scaled(Vector3(s, s, s))
				
				# 1. Le VISUEL est placé exactement à l'origine (le point d'impact du sol)
				var xform_vis = Transform3D(b, result.position)
				multimesh.set_instance_transform(count_placed, xform_vis)

				count_placed += 1
	
	multimesh.visible_instance_count = count_placed
