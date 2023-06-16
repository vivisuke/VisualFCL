extends Node2D

enum {
	OP_AND = 0, OP_OR, OP_NAND,
	OP_GT,		# x1 > x2
	OP_XOR,
	#
	LU_MINI_BATCH = 0, LU_ONLINE, LU_RANDOM_8,
}

var vv_weight = []			# 重みベクターリスト、２次元配列
var vec_first_layer = []	# 1st Layer
var scnd_layer

# ２入力１出力総結合層クラス
# 活性化関数：シグモイド固定
class FC21Unit:
	func _init():
		# 重みベクター初期化
		vec_weight[0] = sin(randf_range(0.0, 2*PI))
		var th = randf_range(0.0, 2*PI)
		vec_weight[1] = cos(th)
		vec_weight[2] = sin(th)
	func sigmoid(x): return 1.0/(1.0 + exp(-x))
	func forward(inp: Array):
		a = vec_weight[0] + vec_weight[1]*inp[0] + vec_weight[2]*inp[1]
		y = sigmoid(a)
		print("a = ", a, ", y = ", y)
	func backward(inp: Array, grad: float):
		upgrad = []		# 上流勾配
		var dyda = y * (1.0 - y)
		var dydag = dyda * grad
		print("∂L/∂y = ", grad)
		print("∂y/∂a = ", dyda)
		upgrad.push_back(dydag)
		upgrad.push_back(dydag * inp[0])
		upgrad.push_back(dydag * inp[1])
	var a			# a = b + w1*x1 + w2*x2
	var y			# y = af(a)、af はシグモイド関数固定
	var vec_weight = [0.0, 0.0, 0.0]	# [b, w1, w2] 重みベクター
	var upgrad							# 上流勾配

# Called when the node enters the scene tree for the first time.
func _ready():
	vec_first_layer = []
	vec_first_layer.push_back(FC21Unit.new())
	vec_first_layer.push_back(FC21Unit.new())
	scnd_layer = FC21Unit.new()
	vv_weight = []
	for i in range(2):
		var w = []
		w.push_back(sin(randf_range(0.0, 2*PI)))
		var th = randf_range(0.0, 2*PI)
		w.push_back(cos(th))
		w.push_back(sin(th))
		vv_weight.push_back(w)
	$GraphRect_1.vv_weight = vv_weight
	$GraphRect_1.ope = OP_XOR
	$GraphRect_1.queue_redraw()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_top_button_pressed():
	get_tree().change_scene_to_file("res://top_scene.tscn")
	pass # Replace with function body.
