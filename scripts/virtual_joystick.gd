extends Control

class_name VirtualJoystick

# Sinal para enviar o vetor de movimento
signal joystick_vector_changed(vector)
signal joystick_released

# Configurações
@export var deadzone: float = 0.2
@export var max_distance: float = 80.0
@export var handle_texture: Texture2D
@export var background_texture: Texture2D

# Nós
@onready var background: TextureRect = $Background
@onready var handle: TextureRect = $Handle

# Variáveis de estado
var is_pressed: bool = false
var touch_index: int = -1
var base_position: Vector2

func _ready():
	# Configurar texturas se fornecidas
	if background_texture:
		background.texture = background_texture
	if handle_texture:
		handle.texture = handle_texture
	
	# Inicializar posições
	base_position = background.position
	handle.position = base_position

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and not is_pressed:
			# Verificar se o toque está dentro da área do joystick
			var local_pos = get_local_mouse_position()
			if Rect2(Vector2.ZERO, size).has_point(local_pos):
				touch_index = event.index
				is_pressed = true
				base_position = local_pos
				background.position = base_position
				handle.position = base_position
				
		elif not event.pressed and event.index == touch_index:
			# Soltou o joystick
			is_pressed = false
			touch_index = -1
			handle.position = base_position
			emit_signal("joystick_vector_changed", Vector2.ZERO)
			emit_signal("joystick_released")
	
	elif event is InputEventScreenDrag and event.index == touch_index and is_pressed:
		update_joystick_position(get_local_mouse_position())

func update_joystick_position(touch_position: Vector2):
	var direction: Vector2 = touch_position - base_position
	var distance: float = direction.length()
	
	# Limitar a distância máxima
	if distance > max_distance:
		direction = direction.normalized() * max_distance
		distance = max_distance
	
	# Aplicar deadzone
	var strength: float = 0.0
	if distance > deadzone * max_distance:
		strength = (distance - deadzone * max_distance) / (max_distance * (1 - deadzone))
	
	# Atualizar posição do handle
	if distance > 0:
		handle.position = base_position + direction.normalized() * min(distance, max_distance)
	else:
		handle.position = base_position
	
	# Calcular vetor normalizado
	var joystick_vector: Vector2
	if strength > 0:
		joystick_vector = direction.normalized() * strength
	else:
		joystick_vector = Vector2.ZERO
	
	# Emitir sinal
	emit_signal("joystick_vector_changed", joystick_vector)

func get_joystick_vector() -> Vector2:
	if is_pressed:
		var direction: Vector2 = handle.position - base_position
		var distance: float = direction.length()
		
		if distance > deadzone * max_distance:
			var strength = (distance - deadzone * max_distance) / (max_distance * (1 - deadzone))
			return direction.normalized() * strength
	
	return Vector2.ZERO
