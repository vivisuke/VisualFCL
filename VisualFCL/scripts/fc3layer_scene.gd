extends Node2D

enum {
	AF_TANH = 0, AF_SIGMOID, AF_RELU,		# 活性化関数種別
	WI_1 = 0, WI_001, WI_XAVIER, WI_HE,		# 重み標準偏差・初期化方法
}
const N_INPUT = 10				# 入力データ数/ミニバッチ
const N_NODE = 2				# 入力、中間、出力ノード数
const N_LAYER = 3				# レイヤー数

var vec_pair = []				# データ配列, 要素：[x, y, bool]
var vec_graph_rect = []
var vec_layer = []

# ニューロンクラス、N入力１出力
# 活性化関数：シグモイド・tanh・ReLU etc ?
class Neuron:
	func _init(n_in, af, deviation:float):
		n_input = n_in
		actv_func = af
		# 重みベクター初期化
		vec_weight.resize(n_input+1)
		if true:
			init_weight(deviation)
		else:
			vec_weight[0] = sin(randf_range(0.0, 2*PI))
			vec_weight[1] = 1.0
			for i in range(n_input-1):
				var th = randf_range(0.0, 2*PI)
				for k in range(n_input-1):
					vec_weight[k+1] *= cos(th)
				vec_weight[i+2] = sin(th)
	func init_weight(deviation:float):
		for i in range(n_input+1):
			vec_weight[i] = randfn(0.0, deviation)
	func sigmoid(x): return 1.0/(1.0 + exp(-x))
	func ReLU(x): return x if x >= 0.0 else 0.0
	func forward(inp: Array):
		a = vec_weight[0]
		for i in range(n_input):
			a += vec_weight[i+1] * inp[i]
		if actv_func == AF_TANH: y = tanh(a)
		elif actv_func == AF_SIGMOID: y = sigmoid(a)
		elif actv_func == AF_RELU: y = ReLU(a)
		#print("a = ", a, ", y = ", y)
	func backward(inp: Array, grad: float):
		upgrad = []		# 上流勾配
		var dyda = y * (1.0 - y)		# sigmoid
		var dydag = dyda * grad
		#print("∂L/∂y = ", grad)
		#print("∂y/∂a = ", dyda)
		upgrad.push_back(dydag)
		for i in range(n_input):
			upgrad.push_back(dydag * inp[i])
	var n_input		# 入力データ数
	var actv_func	# 活性化関数種別
	var vec_weight = []		# [b, w1, w2, w3, ... wN] 重みベクター
	var a					# a = b + w1*x1 + w2*x2 + ... wN*xN
	var y					# y = af(a)、af はシグモイド関数固定
	var upgrad				# 上流勾配
#
class FCLayer:
	func _init(n_in, n_out, af, deviation:float): 
		n_output = n_out
		neuron_lst.resize(n_out)
		for i in range(n_out):
			neuron_lst[i] = Neuron.new(n_in, af, deviation)
	func set_af(af):
		for i in range(n_output):
			neuron_lst[i].actv_func = af
	func set_norm(norm):	# 重み標準偏差設定・重み再計算
		for i in range(n_output):
			neuron_lst[i].init_weight(norm)
	func forward(inp: Array):
		vec_output.resize(n_output)
		for i in range(n_output):
			neuron_lst[i].forward(inp)
			vec_output[i] = neuron_lst[i].y
	var n_output
	var neuron_lst = []
	var vec_output = []

# Called when the node enters the scene tree for the first time.
func _ready():
	vec_graph_rect.push_back($GraphRect_1)
	vec_graph_rect.push_back($GraphRect_2)
	vec_graph_rect.push_back($GraphRect_3)
	for i in range(vec_graph_rect.size()):
		var lbl = Label.new()
		lbl.text = "%d-Layer Input" % (i+1)
		lbl.add_theme_color_override("font_color", Color.BLACK)
		lbl.position = Vector2(102, 0)
		vec_graph_rect[i].add_child(lbl)
		vec_graph_rect[i].to_draw_div_lines = true
		vec_graph_rect[i].to_plot_boolean = false
	vec_layer.resize(N_LAYER)
	for i in range(N_LAYER-1):
		vec_layer[i] = FCLayer.new(N_NODE, N_NODE, AF_TANH, 1/sqrt(2.0))	# Xavier
	vec_layer[N_LAYER-1] = FCLayer.new(N_NODE, 1, AF_SIGMOID, 1/sqrt(2.0))	# Xavier
	init()
	#set_div_line()
	pass # Replace with function body.
func init():
	#vec_input = []
	vec_pair = []
	for i in range(N_INPUT):
		var x1 = randfn(0.0, 1.0)
		#vec_input.push_back(x)
		var x2 = randfn(0.0, 1.0)
		#vec_input.push_back(y)
		vec_pair.push_back([x1, x2, x1*x1+x2*x2<=1.0])
	$GraphRect_1.vec_input = vec_pair
	$GraphRect_1.maxv = 3.0
	$GraphRect_2.maxv = 1.0
	$GraphRect_3.maxv = 1.0
func set_div_line():
	for k in range(N_LAYER):
		var vv_weight = []
		var layer = vec_layer[k]
		layer.set_norm(1/sqrt(2.0))		# Xavier
		for i in range(layer.neuron_lst.size()):
			var vw = layer.neuron_lst[i].vec_weight
			vv_weight.push_back([vw[0], vw[1], vw[2]])
			print("[b, w1, w2] = ", [vw[0], vw[1], vw[2]])
		vec_graph_rect[k].vv_weight = vv_weight
		vec_graph_rect[k].queue_redraw()
func update_graphs():
	for i in range(vec_graph_rect.size()):
		vec_graph_rect[i].queue_redraw()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_top_button_pressed():
	get_tree().change_scene_to_file("res://top_scene.tscn")
	pass # Replace with function body.


func _on_init_button_pressed():
	init()
	set_div_line()
	update_graphs()
	pass # Replace with function body.
