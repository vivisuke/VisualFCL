extends Node2D

enum {
	OP_AND = 0, OP_OR, OP_NAND,
	OP_GT,		# x1 > x2
	OP_XOR,
	#
	LU_MINI_BATCH = 0, LU_ONLINE, LU_RANDOM_8,
}
const boolean_pos = [[0, 0], [1, 0], [0, 1], [1, 1]]

var ALPHA = 0.1				# 学習率
var ope = OP_XOR
var n_train = 0
var n_iteration = 0			# イテレーション数
var sumLoss = 0
var vv_weight = []			# 重みベクターリスト、２次元配列
var vec_first_layer = []	# 1st Layer
var scnd_layer
var vec_input_2nd = []		# 2nd レイヤー入力
var vec_grad_11				# 勾配合計、[∂L/∂b, ∂L/∂w1, ∂L/∂w2]
var vec_grad_12				# 勾配合計
var vec_grad_2				# 勾配合計

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
		#print("a = ", a, ", y = ", y)
	func backward(inp: Array, grad: float):
		upgrad = []		# 上流勾配
		var dyda = y * (1.0 - y)
		var dydag = dyda * grad
		#print("∂L/∂y = ", grad)
		#print("∂y/∂a = ", dyda)
		upgrad.push_back(dydag)
		upgrad.push_back(dydag * inp[0])
		upgrad.push_back(dydag * inp[1])
	var a			# a = b + w1*x1 + w2*x2
	var y			# y = af(a)、af はシグモイド関数固定
	var vec_weight = [0.0, 0.0, 0.0]	# [b, w1, w2] 重みベクター
	var upgrad							# 上流勾配

func init_weight():
	var w = []
	w.push_back(sin(randf_range(0.0, 2*PI)))
	var th = randf_range(0.0, 2*PI)
	w.push_back(cos(th))
	w.push_back(sin(th))
	return w
# Called when the node enters the scene tree for the first time.
func _ready():
	var lbl = Label.new()
	lbl.text = "1st Layer Input" #if i == 0 else "2nd Layer Input"
	lbl.add_theme_color_override("font_color", Color.BLACK)
	lbl.position = Vector2(180, 0)
	$GraphRect_1.add_child(lbl)
	lbl = Label.new()
	lbl.text = "2nd Layer Input"
	lbl.add_theme_color_override("font_color", Color.BLACK)
	lbl.position = Vector2(180, 0)
	$GraphRect_2.add_child(lbl)
	init()
	pass # Replace with function body.
func teacher_value(inp:Array):
	if ope == OP_AND: return 1.0 if inp[0] != 0 && inp[1] != 0.0 else 0.0		# AND
	elif ope == OP_OR: return 1.0 if inp[0] != 0 || inp[1] != 0.0 else 0.0		# OR
	elif ope == OP_NAND: return 0.0 if inp[0] != 0 && inp[1] != 0.0 else 1.0	# NAND
	elif ope == OP_GT: return 1.0 if inp[0] > inp[1] else 0.0					# x1 > x2
	elif ope == OP_XOR: return 1.0 if inp[0] != inp[1] else 0.0					# XOR
	return 0.0
func update_points_in_2ndLayer():
	sumLoss = 0.0
	var n_batch = 0
	vec_input_2nd = []		# 2nd レイヤー入力
	for i in range(boolean_pos.size()):
		n_batch += 1
		vec_first_layer[0].forward(boolean_pos[i])
		var x1 = vec_first_layer[0].y
		vec_first_layer[1].forward(boolean_pos[i])
		var x2 = vec_first_layer[1].y
		#print([x1, x2])
		var t = teacher_value(boolean_pos[i])
		vec_input_2nd.push_back([x1, x2, t!=0.0])
		scnd_layer.forward([x1, x2])
		var d = scnd_layer.y - t
		sumLoss += d * d / 2
	$LossLabel.text = "Loss: %.3f" % (sumLoss/n_batch)
# forward 計算 → bakward 計算、勾配計算、重みには反映させない
func forward_and_backward():
	vec_grad_11 = [0.0, 0.0, 0.0]
	vec_grad_12 = [0.0, 0.0, 0.0]
	vec_grad_2 = [0.0, 0.0, 0.0]
	sumLoss = 0.0
	var n_batch = 0
	vec_input_2nd = []		# 2nd レイヤー入力
	for i in range(boolean_pos.size()):
		n_batch += 1
		var bpos = boolean_pos[i]
		vec_first_layer[0].forward(bpos)
		var x1 = vec_first_layer[0].y
		vec_first_layer[1].forward(bpos)
		var x2 = vec_first_layer[1].y
		#print([x1, x2])
		var t = teacher_value(bpos)
		vec_input_2nd.push_back([x1, x2, t!=0.0])
		scnd_layer.forward([x1, x2])
		var d = scnd_layer.y - t
		sumLoss += d * d / 2
		scnd_layer.backward([x1, x2], d)
		vec_first_layer[0].backward(bpos, scnd_layer.upgrad[1])
		vec_first_layer[1].backward(bpos, scnd_layer.upgrad[2])
		for k in range(3):
			vec_grad_11[k] += vec_first_layer[0].upgrad[k]
			vec_grad_12[k] += vec_first_layer[1].upgrad[k]
			vec_grad_2[k] += scnd_layer.upgrad[k]
	$LossLabel.text = "Loss: %.3f" % (sumLoss/n_batch)
func init():
	n_iteration = 0
	n_train = 0
	$ItrLabel.text = "Iteration: %d" % n_iteration
	vec_first_layer = []
	vec_first_layer.push_back(FC21Unit.new())
	vec_first_layer.push_back(FC21Unit.new())
	scnd_layer = FC21Unit.new()
	vv_weight = []
	for i in range(2):
		var w = init_weight()
		#for k in range(3): w[k] *= 3		# for テスト
		vv_weight.push_back(w)
		vec_first_layer[i].vec_weight = w
	scnd_layer.vec_weight = init_weight()
	#update_points_in_2ndLayer()
	forward_and_backward()
	update_view()
	#print("vec_grad_11 = ", vec_grad_11)
	#print("vec_grad_12 = ", vec_grad_12)
	#print("vec_grad_2 = ", vec_grad_2)
func update_view():
	$Weight11Label.text = "[b, w1, w2]: [%.3f, %.3f, %.3f]" % vec_first_layer[0].vec_weight
	$Weight12Label.text = "[b, w1, w2]: [%.3f, %.3f, %.3f]" % vec_first_layer[1].vec_weight
	$GraphRect_1.ope = ope
	$GraphRect_1.vv_weight = vv_weight
	$GraphRect_1.queue_redraw()
	$Weight2Label.text = "[b, w1, w2]: [%.3f, %.3f, %.3f]" % scnd_layer.vec_weight
	$Grad11Label.text = "∂L/∂[b, w1, w2]: [%.3f, %.3f, %.3f]" % vec_grad_11
	$Grad12Label.text = "∂L/∂[b, w1, w2]: [%.3f, %.3f, %.3f]" % vec_grad_12
	$Grad2Label.text = "∂L/∂[b, w1, w2]: [%.3f, %.3f, %.3f]" % vec_grad_2
	$GraphRect_2.vec_input = vec_input_2nd
	$GraphRect_2.vv_weight = [scnd_layer.vec_weight]
	$GraphRect_2.queue_redraw()
func train(inp:Array):
	vec_first_layer[0].forward(inp)
	var x1 = vec_first_layer[0].y
	vec_first_layer[1].forward(inp)
	var x2 = vec_first_layer[1].y
	#print([x1, x2])
	var t = teacher_value(inp)
	vec_input_2nd.push_back([x1, x2, t!=0.0])
	scnd_layer.forward([x1, x2])
	var d = scnd_layer.y - t
	sumLoss += d * d / 2
	scnd_layer.backward([x1, x2], d)
	pass
func do_train():
	ALPHA = float($LearningRate.text)
	for i in range(3):
		vec_first_layer[0].vec_weight[i] -= vec_grad_11[i] * ALPHA
		vec_first_layer[1].vec_weight[i] -= vec_grad_12[i] * ALPHA
		scnd_layer.vec_weight[i] -= vec_grad_2[i] * ALPHA
	forward_and_backward()
	update_view()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if n_train > 0:
		n_iteration += 1
		$ItrLabel.text = "Iteration: %d" % n_iteration
		n_train -= 1
		do_train()
	pass
func _on_top_button_pressed():
	get_tree().change_scene_to_file("res://top_scene.tscn")
	pass # Replace with function body.
func _on_init_button_pressed():
	init()
	pass # Replace with function body.
func _on_train_1_button_pressed():
	do_train()
	pass # Replace with function body.


func _on_train_100_button_pressed():
	n_train += 100
	pass # Replace with function body.


func _on_train_500_button_pressed():
	n_train += 500
	pass # Replace with function body.


func _on_operator_button_item_selected(index):
	ope = index
	#$GraphRect_1.ope = index
	#$GraphRect_2.ope = index
	forward_and_backward()
	update_view()
	pass # Replace with function body.
