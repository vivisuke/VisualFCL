extends Node2D

enum {
	OP_AND = 0, OP_OR, OP_NAND,
	OP_GT,		# x1 > x2
	OP_XOR,
}
const boolean_pos = [[0, 0], [1, 0], [0, 1], [1, 1]]
var ALPHA = 0.1			# 学習率
var round = 0						# ラウンド数
var ope = OP_AND
var n_train
var n_batch
var sumLoss
var fcl
var vec_weight = [0.0, 0.7, 0.7]			# [b, w1, w2] 重みベクター

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
		a = vec_weight[0] + vec_weight[0]*inp[0] + vec_weight[0]*inp[1]
		y = sigmoid(a)
	var a
	var y
	var vec_weight = [0.0, 0.7, 0.7]			# [b, w1, w2] 重みベクター

# Called when the node enters the scene tree for the first time.
func _ready():
	fcl = FCLayer21.new()
	init()
	pass # Replace with function body.
func init():
	round = 0
	# 重みベクター初期化
	vec_weight[0] = sin(randf_range(0.0, 2*PI))
	var th = randf_range(0.0, 2*PI)
	vec_weight[1] = cos(th)
	vec_weight[2] = sin(th)
	$WeightLabel.text = "[b, w1, w2]: [%.3f, %.3f, %.3f]" % vec_weight
	$GraphRect.vec_weight = vec_weight
	$GraphRect.queue_redraw()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _on_init_button_pressed():
	init()
	pass # Replace with function body.
func teacher_val(inp:Array):
	if ope == OP_AND: return 1.0 if inp[0] != 0 && inp[1] != 0.0 else 0.0		# AND
	elif ope == OP_OR: return 1.0 if inp[0] != 0 || inp[1] != 0.0 else 0.0		# OR
	elif ope == OP_NAND: return 0.0 if inp[0] != 0 && inp[1] != 0.0 else 1.0		# NAND
	elif ope == OP_GT: return 1.0 if inp[0] > inp[1] else 0.0					# x1 > x2
	elif ope == OP_XOR: return 1.0 if inp[0] != inp[1] else 0.0					# XOR
	return 0.0
	
func train(inp:Array):
	n_batch += 1
	fcl.forward(inp)
	var t = teacher_val(inp)
	var d = fcl.y - t
	var L = d * d / 2
	sumLoss += L
func do_train():
	sumLoss = 0.0
	n_batch = 0
	fcl.vec_weight = vec_weight
	for i in range(boolean_pos.size()):
		train(boolean_pos[i])
	print("sumLoss = ", sumLoss)
	$LossLabel.text = "Loss: %.3f" % (sumLoss/n_batch)
func _on_train_1_button_pressed():
	do_train()
	pass # Replace with function body.
