extends Node3D

@export var sensiblidade = 1.0
@export var velocidade = 25.0
@onready var Pai = get_parent()

var cam_horizontal = 0.0
var cam_vertical = 0.0
var Min = -80
var Max = 100

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	cam_vertical = clamp(cam_vertical, Min, Max)
	
	$H.rotation_degrees.y = lerpf($H.rotation_degrees.y, cam_horizontal, velocidade * delta)
	$H/V.rotation_degrees.x = lerpf($H/V.rotation_degrees.y, cam_vertical, velocidade * delta)

func _input(event):
	if event is InputEventMouseMotion:
		cam_horizontal -= event.relative.x * sensiblidade
		cam_vertical -= event.relative.y * sensiblidade
