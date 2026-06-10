extends Node3D

@onready var fade_anim = $FadeOverlay/FadeAnim
@onready var fade_overlay = $FadeOverlay
@onready var black_screen = $FadeOverlay/BlackScreen
@onready var camera_anim = $AnimPlayer
@onready var alarm_sound = $AlarmSound
@onready var cutscene_camera = $Camera3D
@onready var protagonist = $Protagonist
@onready var clock = $Clock
@onready var ItemDrop = $ItemDrop
@onready var Shout = $Shout
@onready var TurnOverAndLament = $TurnOverAndLament
@onready var ContactQuilt = $ContactQuilt


func _ready():
	print("fade_overlay: ", fade_overlay)
	print("fade_anim: ", fade_anim)
	print("black_screen: ", black_screen)

	if black_screen:
		black_screen.color = Color(0, 0, 0, 1)

	# 1. 播放黑幕淡出动画（睁眼）
	if fade_anim:
		fade_anim.play("EyeOpen")
		# 用 CONNECT_ONE_SHOT: 确保回调只触发一次，避免末尾再次播放 EyeOpen 时循环触发
		fade_anim.animation_finished.connect(_on_eye_open_finished, CONNECT_ONE_SHOT)
	else:
		print("错误：找不到 FadeAnim")

	# 2. 播放相机动画（3秒）
	if camera_anim:
		camera_anim.play("CameraMove1")
	else:
		print("错误：找不到 AnimPlayer")


func _on_eye_open_finished(_anim_name):
	print("睁眼动画结束")

	# 3. 播放闹钟音效
	if alarm_sound:
		alarm_sound.play()

	# 等待相机动画播放完（如果还在播）
	if camera_anim and camera_anim.is_playing():
		print("等待相机动画结束...")
		await camera_anim.animation_finished
		print("相机动画已结束")

	await get_tree().create_timer(1).timeout
	# 现在切换相机到主角脸部
	print("瞬间切到主角脸部")
	camera_anim.play("CameraMove2")
	await get_tree().create_timer(1).timeout
	if TurnOverAndLament:
		TurnOverAndLament.play()
	await get_tree().create_timer(1.2).timeout
	if ContactQuilt:
		ContactQuilt.play()

	await camera_anim.animation_finished
	print("相机已切换到主角脸部")

	# 播放碎片动画
	await get_tree().create_timer(0.65).timeout
	camera_anim.play("CameraMove3")
	await camera_anim.animation_finished
	await get_tree().create_timer(0.6).timeout
	camera_anim.play("FocusOnClock")
	await get_tree().create_timer(1).timeout
	if Shout:
		Shout.play()
	await get_tree().create_timer(3.8).timeout
	if ItemDrop:
		ItemDrop.play()

	# 停止闹钟（此时动画已播完，闹钟可以停了）
	if alarm_sound:
		alarm_sound.stop()

	await get_tree().create_timer(2.7).timeout

	# 最后一次睁眼（起床前再次睁眼）
	# 由于上面用了 CONNECT_ONE_SHOT, 这次 EyeOpen 完成后不会触发 _on_eye_open_finished
	fade_anim.play("EyeOpen")
	await get_tree().create_timer(0.5).timeout

	# 播放起床动画
	camera_anim.play("GetUp")
	await camera_anim.animation_finished
	print("起床动画结束，开场序列完成！")

	# 切换到卧室行走场景
	get_tree().change_scene_to_file("res://mainGameScene/Bedroom.tscn")
