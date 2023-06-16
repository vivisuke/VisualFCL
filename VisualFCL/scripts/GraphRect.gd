extends ColorRect


enum {
	UNIFORM_DISTRIBUTION = 0,		# 一様分布
	NORMAL_DISTRILBUTION,			# 正規分布
	EQUAL_DISTRIBUTION,				# 等分割分布
	#
	DSP_001 = 0,				# 0.01
	DSP_XAVIER,
	DSP_HE,
	#
	OP_AND = 0, OP_OR, OP_NAND,
	OP_GT,		# x1 > x2
	OP_XOR,
}
var SZ = self.size
var SCREEN_WD = SZ.x
var SCREEN_HT = SZ.y
const SPACE_TOP = 20.0
const SPACE_BOTTOM = 40.0
const SPACE_LEFT = 40.0
var GRAPH_HT = SCREEN_HT - (SPACE_TOP + SPACE_BOTTOM)
var GRAPH_WD = GRAPH_HT
const SCALE_WD = 6				# 目盛り幅
const LLT = 8
const LT = SPACE_LEFT
var RT = SPACE_LEFT + GRAPH_WD
const TOP = SPACE_TOP
var BTM = SPACE_TOP + GRAPH_HT
const BTM_OFST = 12
const LT_OFST = 12
var ORG_X = SPACE_LEFT + GRAPH_WD/2
var ORG_Y = SPACE_TOP + GRAPH_HT/2

var dispersion = DSP_001					# 重み分散、0.01 | Xavier | He
var distribution = UNIFORM_DISTRIBUTION		# 分布
var maxv = 2.0								# グラフ範囲
var ope = OP_AND
var n_output_node = 1						# 出力ノード数
var uniform_range = 0.02					# 一様分布範囲
#var param_lst = []							
var vec_weight = [-1.0, 1.0, 1.0]			# [b, w1, w2] 重みベクター
var vv_weight = []							# [[b, w1, w2], [b, w1, w2], ...] 重みベクターリスト
var axis_labels = []
var points = []								# 入力データ配列

# 目盛り値ラベル設置
func add_axis_scale(pos, txt):
	var lbl = Label.new()
	lbl.add_theme_color_override("font_color", Color.BLACK)
	lbl.text = txt
	lbl.position = pos
	add_child(lbl)
	return lbl
# Called when the node enters the scene tree for the first time.
func _ready():
	print(self.size)
	# デフォルト重みベクター初期化
	vec_weight[0] = sin(randf_range(0.0, 2*PI))
	var th = randf_range(0.0, 2*PI)
	vec_weight[1] = cos(th)
	vec_weight[2] = sin(th)
	vv_weight.push_back(vec_weight)
	# 目盛り値ラベル設置
	add_axis_scale(Vector2(ORG_X-BTM_OFST, BTM), "0.0")
	axis_labels.push_back(add_axis_scale(Vector2(ORG_X+GRAPH_WD/4-BTM_OFST, BTM), "%.1f" % (maxv/2)))
	axis_labels.push_back(add_axis_scale(Vector2(RT-BTM_OFST, BTM), "%.1f" % maxv))
	axis_labels.push_back(add_axis_scale(Vector2(ORG_X-GRAPH_WD/4-BTM_OFST, BTM), "-%.1f" % (maxv/2)))
	axis_labels.push_back(add_axis_scale(Vector2(LT-BTM_OFST, BTM), "-%.1f" % maxv))
	add_axis_scale(Vector2(LLT, ORG_Y-LT_OFST), "0.0")
	axis_labels.push_back(add_axis_scale(Vector2(LLT, ORG_Y-GRAPH_HT/4-LT_OFST), "%.1f" % (maxv/2)))
	axis_labels.push_back(add_axis_scale(Vector2(LLT, ORG_Y+GRAPH_HT/4-LT_OFST), "-%.1f" % (maxv/2)))
	axis_labels.push_back(add_axis_scale(Vector2(LLT, TOP-LT_OFST), "%.1f" % maxv))
	#
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func posToScreenPos(pos : Vector2) -> Vector2:
	return Vector2(ORG_X + (pos.x/maxv) * (GRAPH_WD/2), ORG_Y - (pos.y/maxv) * (GRAPH_HT/2))
# f(x, y) = b + w1*x + w2*y = 0 の直線描画
func draw_div_line(p: Array, dashed: bool):
	var b  = p[0]
	var w1 = p[1]
	var w2 = p[2]
	print("b, w1, w2 = ", b, " ", w2, " ", w2)
	print("-w1/w2 = ", -w1/w2)
	print("-b/w2 = ", -b/w2)
	var lst = []
	var x = (-w2*maxv - b) / w1	# y == maxv との接線
	if x >= -maxv && x <= maxv: lst.push_back(Vector2(x, maxv))
	x = (w2*maxv - b) / w1	# y == -maxv との接線
	if x >= -maxv && x <= maxv: lst.push_back(Vector2(x, -maxv))
	var y = (-w1*maxv - b) / w2	# x == maxv との接線
	if y > -maxv && y < maxv: lst.push_back(Vector2(maxv, y))
	y = (w1*maxv - b) / w2	# x == -maxv との接線
	if y > -maxv && y < maxv: lst.push_back(Vector2(-maxv, y))
	if lst.size() == 2:
		var col = (Color.BLUE if w2 > 0 else Color.RED) if !dashed else Color.BLACK
		var p1 = posToScreenPos(lst[0])
		var p2 = posToScreenPos(lst[1])
		if !dashed:
			draw_line(p1, p2, col)
		else:
			draw_dashed_line(p1, p2, col)
	pass
func plot_boolean_sub(pos:Vector2):
	var b = 0
	if ope == OP_AND: b = 1.0 if pos.x != 0 && pos.y != 0.0 else 0.0		# AND
	elif ope == OP_OR: b = 1.0 if pos.x != 0 || pos.y != 0.0 else 0.0		# OR
	elif ope == OP_NAND: b = 0.0 if pos.x != 0 && pos.y != 0.0 else 1.0		# NAND
	elif ope == OP_GT: b = 1.0 if pos.x > pos.y else 0.0					# x1 > x2
	elif ope == OP_XOR: b = 1.0 if pos.x != pos.y else 0.0					# XOR
	var col = Color.BLACK if b else Color.DARK_GRAY
	draw_circle(posToScreenPos(pos), 4.0, col)
func plot_boolean():
	plot_boolean_sub(Vector2(0, 0))
	plot_boolean_sub(Vector2(1, 0))
	plot_boolean_sub(Vector2(0, 1))
	plot_boolean_sub(Vector2(1, 1))
	#draw_circle(posToScreenPos(Vector2(0, 0)), 4.0, Color.BLACK)
	#draw_circle(posToScreenPos(Vector2(1, 0)), 4.0, Color.BLACK)
	#draw_circle(posToScreenPos(Vector2(0, 1)), 4.0, Color.BLACK)
	#draw_circle(posToScreenPos(Vector2(1, 1)), 4.0, Color.BLACK)
func plot_points():
	for i in range(points.size()):
		var x = points[i][0]
		var y = points[i][1]
		draw_circle(posToScreenPos(Vector2(x, y)), 4.0, Color.BLACK)
func _draw():
	print("draw()")
	# 背景＋影 描画
	var style_box = StyleBoxFlat.new()      # 影、ボーダなどを描画するための矩形スタイルオブジェクト
	style_box.bg_color = Color.WHITE   # 矩形背景色
	style_box.shadow_offset = Vector2(0, 4)     # 影オフセット
	style_box.shadow_size = 8                   # 影（ぼかし）サイズ
	style_box.shadow_color = Color.GRAY
	draw_style_box(style_box, Rect2(Vector2(0, 0), self.size))      # style_box に設定した矩形を描画
	# 枠描画
	#draw_line(Vector2(LT, TOP), Vector2(RT, TOP), Color.BLACK)
	#draw_line(Vector2(LT, BTM), Vector2(RT, BTM), Color.BLACK)
	draw_rect(Rect2(Vector2(LT, TOP), Vector2(GRAPH_WD, GRAPH_HT)), Color.BLACK, false)
	# 座標軸描画
	draw_line(Vector2(LT, ORG_Y), Vector2(RT, ORG_Y), Color.GRAY)
	draw_line(Vector2(ORG_X, TOP), Vector2(ORG_X, BTM), Color.GRAY)
	# 目盛りの描画
	#for s in range(0.2, 1.0, 0.2):
	for s in range(25, 100, 25):
		print(s)
		var d = (s/100.0) * (GRAPH_HT/2)
		draw_line(Vector2(LT, ORG_Y-d), Vector2(LT+SCALE_WD, ORG_Y-d), Color.BLACK)
		draw_line(Vector2(RT-SCALE_WD, ORG_Y-d), Vector2(RT, ORG_Y-d), Color.BLACK)
		draw_line(Vector2(LT, ORG_Y+d), Vector2(LT+SCALE_WD, ORG_Y+d), Color.BLACK)
		draw_line(Vector2(RT-SCALE_WD, ORG_Y+d), Vector2(RT, ORG_Y+d), Color.BLACK)
		draw_line(Vector2(ORG_X-d, BTM), Vector2(ORG_X-d, BTM-SCALE_WD), Color.BLACK)
		draw_line(Vector2(ORG_X-d, TOP), Vector2(ORG_X-d, TOP+SCALE_WD), Color.BLACK)
		draw_line(Vector2(ORG_X+d, BTM), Vector2(ORG_X+d, BTM-SCALE_WD), Color.BLACK)
		draw_line(Vector2(ORG_X+d, TOP), Vector2(ORG_X+d, TOP+SCALE_WD), Color.BLACK)
	#
	axis_labels[0].text = "%.1f" % (maxv/2)
	axis_labels[1].text = "%.1f" % maxv
	axis_labels[2].text = "-%.1f" % (maxv/2)
	axis_labels[3].text = "-%.1f" % maxv
	axis_labels[4].text = "%.1f" % (maxv/2)
	axis_labels[5].text = "-%.1f" % (maxv/2)
	axis_labels[6].text = "%.1f" % maxv
	#
	plot_boolean()
	#
	for i in range(vv_weight.size()):
		var vw = vv_weight[i]
		draw_div_line(vw, false)
		var v = vw.duplicate()
		v[0] += 1.0
		draw_div_line(v, true)
		v[0] -= 2.0
		draw_div_line(v, true)
	pass
	
