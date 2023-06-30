extends ColorRect

const NODE_RADIUS = 20.0
const Y_LINE = 40
const X_INPUT = 70
const X_ACT = 175
const X_OUTPUT = 280
const Y_1 = 75+10
const Y_X1 = 150+10
const Y_X2 = 225+10
const X_WEIGHT = 120
const X_AF = 225

var selected = false
var initialized = false
var fnt

func add_label(pos: Vector2, txt: String):
	var dx = 4 if txt.length() == 1 else 8
	var lbl = Label.new()
	lbl.add_theme_color_override("font_color", Color.BLACK)
	lbl.text = txt
	lbl.position = pos - Vector2(dx, 12)
	add_child(lbl)
func add_label_raw(pos: Vector2, txt: String):
	var lbl = Label.new()
	lbl.add_theme_color_override("font_color", Color.BLACK)
	lbl.text = txt
	lbl.position = pos
	add_child(lbl)
# Called when the node enters the scene tree for the first time.
func _ready():
	add_label(Vector2(X_WEIGHT, Y_X1-10-45), "*b")
	add_label(Vector2(X_WEIGHT, Y_X1-10), "*w1")
	add_label(Vector2(X_WEIGHT, Y_X1-10+45), "*w2")
	add_label(Vector2(X_AF, Y_X1-10), "h()")
	#
	add_label_raw(Vector2(X_INPUT, Y_LINE-24), "Affine")
	add_label_raw(Vector2(X_ACT+15, Y_LINE-24), "Actv-Func")
	#var lbl = Label.new()
	#lbl.text = "Hello"
	#lbl.position = Vector2(70, 70)
	#add_child(lbl)
	#lbl.font_color = Color.BLACK
	#lbl.add_theme_color_override("font_color", Color.BLACK)
	#fnt = lbl.get_theme_font("font")
	#lbl.add_theme_color_override("color", Color.BLACK)
	#fnt = Font.new()
	#var sf = SystemFont.new()
	#sf.text = "Hello"
	#sf.position = Vector2(10, 10)
	#add_child(sf)

	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func draw_circle_outline(pos: Vector2, radius, col, txt: String):
	draw_circle(pos, radius, col)
	draw_arc(pos, radius, 0.0, 2*PI, 128, Color.BLACK, 0.75, true)
	#draw_string(fnt, pos, txt)
	if !initialized:
		add_label(pos, txt)
	
func _draw():
	# 背景＋影 描画
	var style_box = StyleBoxFlat.new()      # 影、ボーダなどを描画するための矩形スタイルオブジェクト
	style_box.bg_color = Color.WHITE if !selected else Color.LIGHT_CYAN  # 矩形背景色
	style_box.shadow_offset = Vector2(0, 4)     # 影オフセット
	style_box.shadow_size = 8                   # 影（ぼかし）サイズ
	style_box.shadow_color = Color.GRAY
	draw_style_box(style_box, Rect2(Vector2(0, 0), self.size))      # style_box に設定した矩形を描画
	# エッジ
	draw_line(Vector2(X_INPUT, Y_1), Vector2(X_ACT, Y_X1), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_X1), Vector2(X_ACT, Y_X1), Color.DARK_GRAY)
	draw_line(Vector2(X_INPUT, Y_X2), Vector2(X_ACT, Y_X1), Color.DARK_GRAY)
	draw_line(Vector2(X_ACT, Y_X1), Vector2(X_OUTPUT, Y_X1), Color.DARK_GRAY)
	# ノード
	draw_circle_outline(Vector2(X_INPUT, Y_1), NODE_RADIUS, Color("#e0e0e0"), "1")
	draw_circle_outline(Vector2(X_INPUT, Y_X1), NODE_RADIUS, Color.WHITE, "x1")
	draw_circle_outline(Vector2(X_INPUT, Y_X2), NODE_RADIUS, Color.WHITE, "x2")
	draw_circle_outline(Vector2(X_ACT, Y_X1), NODE_RADIUS, Color.WHITE, "a")
	draw_circle_outline(Vector2(X_OUTPUT, Y_X1), NODE_RADIUS, Color.WHITE, "y")
	# 上部
	draw_line(Vector2(X_INPUT-NODE_RADIUS+5, Y_LINE), Vector2(X_ACT-5, Y_LINE), Color.BLACK)
	draw_line(Vector2(X_ACT+5, Y_LINE), Vector2(X_OUTPUT+NODE_RADIUS-5, Y_LINE), Color.BLACK)

	#
	initialized = true
