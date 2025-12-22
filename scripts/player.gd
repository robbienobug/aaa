extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var anim_tree: AnimationTree = $"T-Pose/AnimationTree"
var smoth = Vector2.ZERO
var with_gun = true
@onready var IK: SkeletonIK3D = $"T-Pose/Skeleton3D/ik"
var h_offset_ao_atirar = 1
var h_offset_normal = 0.0
var h_offset_ao_atirar_bool = false
@onready var gun_fire : AnimationPlayer =  $"T-Pose/Skeleton3D/BoneAttachment3D/Fake_gun/AnimationPlayer"

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("arm"):
		if with_gun == true:
			anim_tree.set("parameters/LocomotionTransition/blend_amount", AnimationNodeBlend2.FILTER_PASS)
			$"T-Pose".rotation.y = 0
			with_gun = false
			IK.start()
			h_offset_ao_atirar_bool = true
		else:
			anim_tree.set("parameters/LocomotionTransition/blend_amount", AnimationNodeBlend2.FILTER_IGNORE)
			with_gun = true
			IK.stop()
			h_offset_ao_atirar_bool = false
			
	if Input.is_action_just_pressed("shoot"):
		IK.start()
		anim_tree.set("parameters/Shoot/active", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		gun_fire.play("shoot")
		anim_tree.set("parameters/LocomotionTransition/blend_amount",AnimationNodeBlend2.FILTER_PASS)
		$"T-Pose".rotation.y = 0
		with_gun = false
		h_offset_ao_atirar_bool = true
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var input_dir := -Input.get_vector("d", "a", "s", "w")
	
	if h_offset_ao_atirar_bool == true:
		$Camera/H/V/SpringArm3D/Camera3D.h_offset = lerpf($Camera/H/V/SpringArm3D/Camera3D.h_offset, h_offset_ao_atirar, delta * 5)
	else:
		_voltar_h_offset(delta)
	
	smoth = lerp(smoth, input_dir, delta * 15)
	anim_tree.set("parameters/BlendTree/LocomotionNoArmed/blend_amount", smoth.length())
	var direction = ($Camera/H.transform.basis.z * -input_dir.y + $Camera/H.transform.basis.x * -input_dir.x).normalized()
	anim_tree.set("parameters/LocomotionArmed/blend_position", Vector2(-direction.x, direction.z))
	
	if with_gun == false:
		$"T-Pose".rotation_degrees.y = $Camera/H.rotation_degrees.y
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		$"T-Pose".rotation.y = lerp_angle($"T-Pose".rotation.y, atan2(direction.x, direction.z), delta * 5)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	move_and_slide()

func _voltar_h_offset(delta):
	$Camera/H/V/SpringArm3D/Camera3D.h_offset = lerpf($Camera/H/V/SpringArm3D/Camera3D.h_offset, h_offset_normal, delta * 5)
