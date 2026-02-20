extends ColorRect

signal fx_grain_size_update(type: int)
signal fx_grain_time_update

var _fx_timer_counter: int = 0
var _fx_timer_speed: int = 38

func _ready() -> void:
	fx_grain_size_update.connect(_on_player_life_update)
	fx_grain_time_update.connect(_on_player_moved)

## This function is magically invoked when the player life is updated
## - when the player lost life: add grain
## - when the player gain life: remove grain
func _on_player_life_update(type: int) -> void: 
	var grain_shader = self.material
	var grain_size = grain_shader.get_shader_parameter("grain_size")
	var grain_amount = grain_shader.get_shader_parameter("grain_amount")
	if type < 0:
		grain_shader.set_shader_parameter("grain_size", grain_size + 0.2)
		grain_shader.set_shader_parameter("grain_amount", grain_amount + 0.01)
		_fx_timer_speed -= 8
	if type > 0:
		grain_shader.set_shader_parameter("grain_size", grain_size - 0.2)
		grain_shader.set_shader_parameter("grain_amount", grain_amount - 0.01)
		_fx_timer_speed += 8

## This function is magically invoked when the player or camera move
## - when a mouvement is detected: animate the shader
## - when the player lost life: slow down the animation
## - when the player gain life: speed up the animation
func _on_player_moved() -> void:
	_fx_timer_counter += 1
	if (_fx_timer_counter % _fx_timer_speed) != 0:
		return
	var grain_shader = self.material
	var grain_time = grain_shader.get_shader_parameter("grain_time")
	grain_shader.set_shader_parameter("grain_time", grain_time + 0.5)
