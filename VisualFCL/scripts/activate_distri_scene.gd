extends Node2D

enum {		# 活性化関数種別
	AF_SIGMOID = 0, AF_TANH, AF_RELU,
}
const N_INPUT = 100				# 入力データ数
const N_NODE = 100				# 中間、出力ノード数

var vec_input = []				# 入力データ配列, [x1, x2, x3, ... xN]
var vec_input_pair = []			# 入力データ配列, 要素：[x, y, bool]
var first_layer
var vec_output_1 = []			# 1st レイヤー出力
var vec_output_1_pair = []		# 1st レイヤー出力, 要素：[x, y, bool]
var vec_output_2 = []			# 1st レイヤー出力
var vec_output_2_pair = []		# 1st レイヤー出力, 要素：[x, y, bool]

# ニューロンクラス、N入力１出力
# 活性化関数：シグモイド・tanh・ReLU etc ?
class Neuron:
	func _init(n_in, af, deviation:float):
		n_input = n_in
		actv_func = af
		# 重みベクター初期化
		vec_weight.resize(n_input+1)
		if true:
			for i in range(n_input+1):
				vec_weight[i] = randfn(0.0, deviation)
		else:
			vec_weight[0] = sin(randf_range(0.0, 2*PI))
			vec_weight[1] = 1.0
			for i in range(n_input-1):
				var th = randf_range(0.0, 2*PI)
				for k in range(n_input-1):
					vec_weight[k+1] *= cos(th)
				vec_weight[i+2] = sin(th)
	func sigmoid(x): return 1.0/(1.0 + exp(-x))
	func forward(inp: Array):
		a = vec_weight[0]
		for i in range(n_input):
			a += vec_weight[i+1] * inp[i]
		#y = sigmoid(a)
		y = tanh(a)
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
	$GraphRect_1.to_draw_div_lines = false
	$GraphRect_2.to_draw_div_lines = false
	$GraphRect_3.to_draw_div_lines = false
	$GraphRect_4.to_draw_div_lines = false
	$GraphRect_5.to_draw_div_lines = false
	$GraphRect_6.to_draw_div_lines = false
	$GraphRect_1.to_plot_boolean = false
	$GraphRect_2.to_plot_boolean = false
	$GraphRect_3.to_plot_boolean = false
	$GraphRect_4.to_plot_boolean = false
	$GraphRect_5.to_plot_boolean = false
	$GraphRect_6.to_plot_boolean = false
	first_layer = FCLayer.new(N_INPUT, N_NODE, AF_TANH, 0.1)
	#for i in range(N_NODE):
	#	first_layer.push_back(FCN1Unit.new(N_INPUT, 0.1))
	init()
	forward()
	pass # Replace with function body.
func init():
	vec_input = []
	vec_input_pair = []
	for i in range(N_INPUT/2):
		var x = randfn(0.0, 1.0)
		vec_input.push_back(x)
		var y = randfn(0.0, 1.0)
		vec_input.push_back(y)
		vec_input_pair.push_back([x, y, false])
	$GraphRect_1.vec_input = vec_input_pair
	$GraphRect_1.maxv = 3.0
	$GraphRect_1.queue_redraw()
	$GraphRect_2.queue_redraw()
	$GraphRect_3.queue_redraw()
	$GraphRect_4.queue_redraw()
	$GraphRect_5.queue_redraw()
	$GraphRect_6.queue_redraw()
func forward():
	first_layer.forward(vec_input)
	var vec_output = first_layer.vec_output
	#vec_output_1 = []
	vec_output_1_pair = []
	for i in range(N_NODE/2):
		#first_layer[i*2].forward(vec_input)
		#vec_output_1.push_back(first_layer[i*2].y)
		#first_layer[i*2+1].forward(vec_input)
		#vec_output_1.push_back(first_layer[i*2+1].y)
		vec_output_1_pair.push_back([vec_output[i*2], vec_output[i*2+1], false])
	$GraphRect_2.vec_input = vec_output_1_pair
	$GraphRect_2.maxv = 1.0
	$GraphRect_2.queue_redraw()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_top_button_pressed():
	get_tree().change_scene_to_file("res://top_scene.tscn")
	pass # Replace with function body.
