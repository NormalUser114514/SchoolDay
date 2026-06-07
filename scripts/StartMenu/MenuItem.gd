extends Panel

var default_alpha = 0      # 默认透明度
var hover_alpha = 150       # 悬停时透明度
var click_alpha = 255       # 点击时透明度（完全不透明）

var stylebox: StyleBoxFlat

func _ready():
	# 获取当前的 StyleBox
	stylebox = get_theme_stylebox("panel").duplicate()
	set_alpha(default_alpha)
	add_theme_stylebox_override("panel", stylebox)
	
	# 连接信号
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

func set_alpha(alpha_value: int):
	var color = stylebox.bg_color
	color.a = alpha_value / 255.0
	stylebox.bg_color = color

func _on_mouse_entered():
	set_alpha(hover_alpha)

func _on_mouse_exited():
	set_alpha(default_alpha)

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		set_alpha(click_alpha)
		# 方法1：使用绝对路径
		get_node("/root/StartMenu").on_menu_item_pressed(name)
