extends Node2D

enum {
	AF_TANH = 0, AF_SIGMOID, AF_RELU,		# 活性化関数種別
	WI_1 = 0, WI_001, WI_XAVIER, WI_HE,		# 重み標準偏差・初期化方法
}
const N_INPUT = 50				# 入力データ数
const N_NODE = 50				# 中間、出力ノード数
const N_LAYER = 5				# レイヤー数

var vec_input = []				# 入力データ配列, [x1, x2, x3, ... xN]
var vec_pair = []				# データ配列, 要素：[x, y, bool]
var first_layer
var vec_layer = []				# レイヤーオブジェクト配列
#var vec_output_1 = []			# 1st レイヤー出力
#var vec_output_1_pair = []		# 1st レイヤー出力, 要素：[x, y, bool]
#var vec_output_2 = []			# 1st レイヤー出力
#var vec_output_2_pair = []		# 1st レイヤー出力, 要素：[x, y, bool]
var vec_graph_rect = []

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
	func set_norm(norm):
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
	vec_graph_rect.push_back($GraphRect_4)
	vec_graph_rect.push_back($GraphRect_5)
	vec_graph_rect.push_back($GraphRect_6)
	for i in range(vec_graph_rect.size()):
		var lbl = Label.new()
		lbl.text = "Input" if i == 0 else ("Layer-%d" % i)
		lbl.add_theme_color_override("font_color", Color.BLACK)
		lbl.position = Vector2(130, 0)
		vec_graph_rect[i].add_child(lbl)
		vec_graph_rect[i].to_draw_div_lines = false
		vec_graph_rect[i].to_plot_boolean = false
	#$GraphRect_1.to_draw_div_lines = false
	#$GraphRect_2.to_draw_div_lines = false
	#$GraphRect_3.to_draw_div_lines = false
	#$GraphRect_4.to_draw_div_lines = false
	#$GraphRect_5.to_draw_div_lines = false
	#$GraphRect_6.to_draw_div_lines = false
	#$GraphRect_1.to_plot_boolean = false
	#$GraphRect_2.to_plot_boolean = false
	#$GraphRect_3.to_plot_boolean = false
	#$GraphRect_4.to_plot_boolean = false
	#$GraphRect_5.to_plot_boolean = false
	#$GraphRect_6.to_plot_boolean = false
	vec_layer.resize(N_LAYER)
	for i in range(N_LAYER):
		vec_layer[i] = FCLayer.new(N_INPUT, N_NODE, AF_TANH, 0.1414)
	#first_layer = FCLayer.new(N_INPUT, N_NODE, AF_TANH, 0.1)
	#for i in range(N_NODE):
	#	first_layer.push_back(FCN1Unit.new(N_INPUT, 0.1))
	init()
	forward()
	pass # Replace with function body.
func init():
	vec_input = []
	vec_pair = []
	for i in range(N_INPUT/2):
		var x = randfn(0.0, 1.0)
		vec_input.push_back(x)
		var y = randfn(0.0, 1.0)
		vec_input.push_back(y)
		vec_pair.push_back([x, y, false])
	$GraphRect_1.vec_input = vec_pair
	$GraphRect_1.maxv = 3.0
	#$GraphRect_1.queue_redraw()
	#$GraphRect_2.queue_redraw()
	#$GraphRect_3.queue_redraw()
	#$GraphRect_4.queue_redraw()
	#$GraphRect_5.queue_redraw()
	#$GraphRect_6.queue_redraw()
func forward():
	var tmp = vec_input
	for k in range(N_LAYER):
		vec_layer[k].forward(tmp)
		tmp = vec_layer[k].vec_output
		vec_pair = []
		for i in range(N_NODE/2):
			vec_pair.push_back([tmp[i*2], tmp[i*2+1], false])
		vec_graph_rect[k+1].vec_input = vec_pair
		vec_graph_rect[k+1].maxv = 1.0
		vec_graph_rect[k+1].queue_redraw()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _on_top_button_pressed():
	get_tree().change_scene_to_file("res://top_scene.tscn")
func _on_actv_func_button_item_selected(index):
	for k in range(N_LAYER):
		vec_layer[k].set_af(index)
	forward()
func _on_wt_init_type_button_item_selected(index):
	var norm
	if index == WI_1: norm = 1.0
	elif index == WI_001: norm = 0.001
	elif index == WI_XAVIER: norm = 1.0/sqrt(N_INPUT)
	elif index == WI_HE: norm = sqrt(2.0/N_INPUT)
	print("norm = ", norm)
	for k in range(N_LAYER):
		vec_layer[k].set_norm(norm)
	forward()
