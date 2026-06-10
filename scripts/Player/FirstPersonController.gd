extends CharacterBody3D

## 第一人称玩家控制器 — 跳跃、疾跑、手臂摆动

# 移动参数
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 9.0
@export var acceleration: float = 40.0
@export var friction: float = 60.0

# 跳跃参数
@export var jump_height: float = 1.5
@export var jump_time_to_peak: float = 0.4
@export var jump_time_to_descend: float = 0.3

# 视角参数
@export var mouse_sensitivity: float = 0.003
@export_range(1, 89) var look_up_limit: int = 60
@export_range(-89, -1) var look_down_limit: int = -60

# 手臂摆动参数
@export var arm_swing_frequency: float = 1.5
@export var arm_swing_amount: float = 20.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var skeleton: Skeleton3D = $Protagonist

var _current_speed: float = 0.0
var _was_moving: bool = false
var _walk_cycle: float = 0.0

# 跳跃参数（自动计算）
var _jump_velocity: float:
	get: return 2.0 * jump_height / jump_time_to_peak
var _jump_gravity: float:
	get: return -2.0 * jump_height / (jump_time_to_peak * jump_time_to_peak)
var _fall_gravity: float:
	get: return -2.0 * jump_height / (jump_time_to_descend * jump_time_to_descend)

# 手臂骨骼索引
var _left_arm_idx: int = -1
var _right_arm_idx: int = -1


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.make_current()
	
	# 获取手臂骨骼索引
	if skeleton:
		for i in skeleton.get_bone_count():
			var name = skeleton.get_bone_name(i)
			if name == "mixamorig_LeftArm":
				_left_arm_idx = i
			elif name == "mixamorig_RightArm":
				_right_arm_idx = i


func _input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(look_down_limit), deg_to_rad(look_up_limit))


func _physics_process(delta):
	# 输入方向
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	input_dir = -input_dir  # 修正方向
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var is_moving := direction.length() > 0.0
	
	# 重力
	_apply_gravity(delta)
	
	# 跳跃
	_handle_jump()
	
	# 移动（加速/减速）
	var target_speed := sprint_speed if Input.is_action_pressed("sprint") and is_moving else walk_speed
	
	if is_moving:
		_current_speed = move_toward(_current_speed, target_speed, acceleration * delta)
		velocity.x = direction.x * _current_speed
		velocity.z = direction.z * _current_speed
	else:
		_current_speed = move_toward(_current_speed, 0.0, friction * delta)
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.z = move_toward(velocity.z, 0.0, friction * delta)
	
	move_and_slide()
	
	# 落地后 y 速度归零
	if is_on_floor() and velocity.y < 0:
		velocity.y = 0
	
	# 手臂摆动
	_update_arm_swing(delta, is_moving)


func _apply_gravity(delta: float):
	if not is_on_floor():
		var gravity := _jump_gravity if velocity.y > 0 else _fall_gravity
		velocity.y += gravity * delta


func _handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = _jump_velocity


func _update_arm_swing(delta: float, is_moving: bool):
	if _left_arm_idx < 0 or _right_arm_idx < 0:
		return
	
	if is_moving and is_on_floor():
		_walk_cycle += delta * _current_speed * arm_swing_frequency
		
		var swing_rot := sin(_walk_cycle) * deg_to_rad(arm_swing_amount)
		skeleton.set_bone_pose_rotation(_left_arm_idx, Quaternion(Vector3.RIGHT, swing_rot))
		skeleton.set_bone_pose_rotation(_right_arm_idx, Quaternion(Vector3.RIGHT, -swing_rot))
		_was_moving = true
	else:
		if _was_moving:
			# 平滑恢复
			var rest := Quaternion.IDENTITY
			var l_rot := skeleton.get_bone_pose_rotation(_left_arm_idx)
			var r_rot := skeleton.get_bone_pose_rotation(_right_arm_idx)
			l_rot = l_rot.slerp(rest, 0.2)
			r_rot = r_rot.slerp(rest, 0.2)
			skeleton.set_bone_pose_rotation(_left_arm_idx, l_rot)
			skeleton.set_bone_pose_rotation(_right_arm_idx, r_rot)
			_walk_cycle = 0.0
			if l_rot.is_equal_approx(rest):
				_was_moving = false
