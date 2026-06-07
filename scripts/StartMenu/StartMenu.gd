extends Control

@onready var anim_player = $MenuPanel/LinkButtons/AnimPlayer
@onready var exit_dialog = $ExitConfirmDialog

# 预加载场景（可选，让切换更快）
const OPENING_SCENE = preload("res://mainGameScene/Opening.tscn")

func _ready():
	print("exit_dialog 节点: ", exit_dialog)
	anim_player.play("menu_enter")
	
	# 连接对话框的信号
	exit_dialog.confirmed.connect(_on_exit_confirmed)
	# 取消不需要处理，对话框会自动关闭

func on_menu_item_pressed(item_name: String):
	match item_name:
		"StartLinkBg":
			print("开始游戏")
			# 切换到开场动画场景
			get_tree().change_scene_to_file("res://mainGameScene/Opening.tscn")
			# 或者用预加载的写法：
			# get_tree().change_scene_to_packed(OPENING_SCENE)
		"SettingsLinkBg":
			print("打开设置")
		"QuitLinkBg":
			print("退出游戏")
			exit_dialog.popup_centered()

func _on_exit_confirmed():
	print("退出游戏")
	get_tree().quit()
