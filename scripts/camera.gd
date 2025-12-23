extends Node3D

@export var sensibilidade : float = 0.2  # Melhor usar valor pequeno para touch
@export var velocidade : float = 25.0

var cam_horizontal : float = 0.0
var cam_vertical : float = 0.0
var Min : float = -40
var Max : float = 45

# Variáveis para toque da câmera
var camera_touch_index : int = -1  # -1 = nenhum toque ativo para câmera
var half_screen_x : float

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Em mobile isto não faz nada, mas ok
	half_screen_x = ProjectSettings.get_setting("display/window/size/viewport_width") / 2.0

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	cam_vertical = clamp(cam_vertical, Min, Max)
	
	$H.rotation_degrees.y = lerpf($H.rotation_degrees.y, cam_horizontal, velocidade * delta)
	$H/V.rotation_degrees.x = lerpf($H/V.rotation_degrees.x, cam_vertical, velocidade * delta)

func _input(event):
	# Só processamos eventos de toque na metade direita da tela para a câmera
	if event is InputEventScreenTouch:
		if event.pressed:
			# Toque começou: verifica se é na direita
			if event.position.x > half_screen_x and camera_touch_index == -1:
				camera_touch_index = event.index
		else:
			# Toque acabou
			if event.index == camera_touch_index:
				camera_touch_index = -1
	
	elif event is InputEventScreenDrag:
		# Só reage ao drag do toque que começou na direita
		if event.index == camera_touch_index:
			cam_horizontal -= event.relative.x * sensibilidade
			cam_vertical -= event.relative.y * sensibilidade
	
	# Opcional: suportar mouse no PC (ignora índices)
	elif event is InputEventMouseMotion and camera_touch_index == -1:
		cam_horizontal -= event.relative.x * sensibilidade
		cam_vertical -= event.relative.y * sensibilidade
