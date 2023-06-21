extends Node2D

const N_INPUT = 100				# 入力データ数
const N_NODE = 100				# 中間ノード数

var vec_input = []				# 入力データ配列, [x, y, bool]
var first_layer

# N入力１出力総結合層クラス
# 活性化関数：シグモイド固定
class FCN1Unit:
	func _init(n_in, deviation):
		n_input = n_in
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
			a += vec_weight[i+1]*inp[i]
		y = sigmoid(a)
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
	var a			# a = b + w1*x1 + w2*x2 + ... wN*xN
	var y			# y = af(a)、af はシグモイド関数固定
	var n_input		# 入力データ数
	var vec_weight = []			# [b, w1, w2, w3, ... wN] 重みベクター
	var upgrad					# 上流勾配

# Called when the node enters the scene tree for the first time.
func _ready():
	first_layer = FCN1Unit.new(N_INPUT, 1.0)
	init()
	pass # Replace with function body.
func init():
	vec_input = []
	for i in range(N_INPUT/2):
		var x = randfn(0.0, 1.0)
		var y = randfn(0.0, 1.0)
		vec_input.push_back([x, y, true])
	$GraphRect_1.vec_input = vec_input
	$GraphRect_1.maxv = 3.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_top_button_pressed():
	get_tree().change_scene_to_file("res://top_scene.tscn")
	pass # Replace with function body.
