extends Node2D

enum {
	OP_AND = 0, OP_OR, OP_NAND,
	OP_GT,		# x1 > x2
	OP_XOR,
}
var ALPHA = 0.1			# 学習率
var round = 0						# ラウンド数
var ope = OP_AND
var vec_weight = [0.0, 0.7, 0.7]			# [b, w1, w2] 重みベクター

# Called when the node enters the scene tree for the first time.
func _ready():
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
