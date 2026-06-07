extends Node3D

@onready var fade_anim = $FadeOverlay/FadeAnim
@onready var fade_overlay = $FadeOverlay
@onready var black_screen = $FadeOverlay/BlackScreen
@onready var camera_anim = $AnimPlayer
@onready var alarm_sound = $AlarmSound
@onready var cutscene_camera = $Camera3D
@onready var protagonist = $Protagonist
@onready var clock = $Clock
@onready var ItemDrop=$ItemDrop
@onready var Shout=$Shout
@onready var TurnOverAndLament=$TurnOverAndLament
@onready var ContactQuilt=$ContactQuilt

func _ready():
	print("fade_overlay: ", fade_overlay)
	print("fade_anim: ", fade_anim)
	print("black_screen: ", black_screen)
	
	if black_screen:
		black_screen.color = Color(0, 0, 0, 1)
	
	# 1. 播放黑幕淡出动画（睁眼）
	if fade_anim:
		fade_anim.play("EyeOpen")
		fade_anim.animation_finished.connect(_on_eye_open_finished)
	else:
		print("错误：找不到 FadeAnim")
	
	# 2. 播放相机动画（3秒）
	if camera_anim:
		camera_anim.play("CameraMove1")
		# 相机动画结束时不直接切，等睁眼动画结束后再判断
	else:
		print("错误：找不到 AnimPlayer")

func _on_eye_open_finished(anim_name):
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
	
	#播放碎片动画
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
	alarm_sound.stop()
	await get_tree().create_timer(2.7).timeout
	fade_anim.play("EyeOpen")
	await get_tree().create_timer(0.5).timeout
	camera_anim.play("GetUp")
