extends Node2D

enum {
	OP_AND = 0, OP_OR, OP_NAND,
	OP_GT,		# x1 > x2
	OP_XOR,
	#
	LU_MINI_BATCH = 0, LU_ONLINE, LU_RANDOM_8,
}
const boolean_pos = [[0, 0], [1, 0], [0, 1], [1, 1]]
var ALPHA = 0.1			# 学習率
#var round = 0						# ラウンド数
var ope = OP_AND
var n_train = 0
var n_iteration = 0					# イテレーション数
var n_batch
var learn_unit = LU_MINI_BATCH
var sumLoss
var fcl
var vec_weight = [0.0, 0.7, 0.7]	# [b, w1, w2] 重みベクター
var vec_grad						# 勾配合計

# ２入力１出力総結合層クラス
# 活性化関数：シグモイド固定
class FCLayer21:
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
	fcl = FCLayer21.new()
	init()
	pass # Replace with function body.
func init():
	#round = 0
	n_iteration = 0
	n_train = 0
	# 重みベクター初期化
	if true:
		vec_weight[0] = sin(randf_range(0.0, 2*PI))
		var th = randf_range(0.0, 2*PI)
		vec_weight[1] = cos(th)
		vec_weight[2] = sin(th)
	else:		# for Debug
		vec_weight[0] = -2.0
		vec_weight[1] = 1.0
		vec_weight[2] = 1.0
	$ItrLabel.text = "Iteration: 0"
	$WeightLabel.text = "[b, w1, w2]: [%.3f, %.3f, %.3f]" % vec_weight
	$GraphRect.vec_weight = vec_weight
	$GraphRect.queue_redraw()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if n_train > 0:
		n_iteration += 1
		$ItrLabel.text = "Iteration: %d" % n_iteration
		n_train -= 1
		do_train()
	pass
func _on_init_button_pressed():
	init()
	pass # Replace with function body.
func teacher_value(inp:Array):
	if ope == OP_AND: return 1.0 if inp[0] != 0 && inp[1] != 0.0 else 0.0		# AND
	elif ope == OP_OR: return 1.0 if inp[0] != 0 || inp[1] != 0.0 else 0.0		# OR
	elif ope == OP_NAND: return 0.0 if inp[0] != 0 && inp[1] != 0.0 else 1.0		# NAND
	elif ope == OP_GT: return 1.0 if inp[0] > inp[1] else 0.0					# x1 > x2
	elif ope == OP_XOR: return 1.0 if inp[0] != inp[1] else 0.0					# XOR
	return 0.0
	
func train(inp:Array):
	n_batch += 1
	fcl.forward(inp)
	var t = teacher_value(inp)
	var d = fcl.y - t
	var L = d * d / 2
	sumLoss += L
	fcl.backward(inp, d)
	vec_grad[0] += fcl.upgrad[0]
	vec_grad[1] += fcl.upgrad[1]
	vec_grad[2] += fcl.upgrad[2]
func do_train():
	vec_grad = [0.0, 0.0, 0.0]
	sumLoss = 0.0
	n_batch = 0
	fcl.vec_weight = vec_weight
	if learn_unit == LU_MINI_BATCH:		# ミニバッチ学習
		for i in range(boolean_pos.size()):
			train(boolean_pos[i])
	elif learn_unit == LU_ONLINE:			# オンライン学習
		var r = randi_range(0, boolean_pos.size()-1)
		train(boolean_pos[r])
	else:
		for i in range(8):
			var r = randi_range(0, boolean_pos.size()-1)
			train(boolean_pos[r])
	print("sumLoss = ", sumLoss)
	$LossLabel.text = "Loss: %.3f" % (sumLoss/n_batch)
	print("vec_grad = ", vec_grad)
	vec_weight[0] -= ALPHA * vec_grad[0]
	vec_weight[1] -= ALPHA * vec_grad[1]
	vec_weight[2] -= ALPHA * vec_grad[2]
	$WeightLabel.text = "[b, w1, w2]: [%.3f, %.3f, %.3f]" % vec_weight
	$GraphRect.vec_weight = vec_weight
	$GraphRect.queue_redraw()
func _on_train_1_button_pressed():
	ALPHA = float($LearningRate.text)
	do_train()
	pass # Replace with function body.
func _on_train_100_button_pressed():
	n_train = 100
	ALPHA = float($LearningRate.text)
	pass # Replace with function body.
func _on_train_500_button_pressed():
	n_train = 500
	ALPHA = float($LearningRate.text)
	pass # Replace with function body.
func _on_operator_button_item_selected(index):
	ope = index
	$GraphRect.ope = ope
	$GraphRect.queue_redraw()
	pass # Replace with function body.
func _on_learn_unit_button_item_selected(index):
	learn_unit = index
	pass # Replace with function body.
