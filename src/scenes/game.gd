extends Node3D

# todo: find a better shader value
# todo: merge CanvasLayer2 and CanvasLayer
# todo: properly rename node
func _input(event: InputEvent) -> void:
	var grain_shader = $CanvasLayer2/Grain.material
	var grain_size = grain_shader.get_shader_parameter("grain_size")
	var grain_amount = grain_shader.get_shader_parameter("grain_amount")
	if event.is_action_pressed("ui_cancel"):
		if $Player.current_life > 0:
			grain_shader.set_shader_parameter("grain_size", grain_size + 0.2)
			#grain_shader.set_shader_parameter("grain_amount", grain_amount + 0.01)
	if event.is_action_pressed("ui_select"):
		# fixme: use signal to avoid sync error as follow:
		#	1. Player._input -> $Player.current_life++
		#   2. (next line)   -> false
		# So, the original value of `grain_size` will be never meet. By using
		# "signal" or other sync features, we will be assured that an update
		# has been performed on the player life
		if $Player.current_life < $Player.max_life:
			grain_shader.set_shader_parameter("grain_size", grain_size - 0.2)
			#grain_shader.set_shader_parameter("grain_amount", grain_amount - 0.01)
