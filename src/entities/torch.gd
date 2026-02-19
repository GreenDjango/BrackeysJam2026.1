extends OmniLight3D

@export var vitesse_flamme = 2.0
@export var intensite_flamme = 0.2
@export var instabilite = 0.2
@export var particles_node : CPUParticles3D

var base_energy = 1.0
var base_range = 8.0
var cible_energy = 1.0

func _ready():
	base_energy = light_energy
	base_range = omni_range
	cible_energy = base_energy

func _process(delta):
	if abs(light_energy - cible_energy) < 0.1:
		cible_energy = base_energy + randf_range(-intensite_flamme, intensite_flamme)
	light_energy = lerp(light_energy, cible_energy, vitesse_flamme * delta)
	var tremblement = randf_range(-instabilite, instabilite)
	var current_life : int = get_tree().get_nodes_in_group("player")[0].current_life
	omni_range = ((base_range * current_life * 0.5) * (light_energy / base_energy)) + tremblement
