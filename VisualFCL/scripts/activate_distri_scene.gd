extends Node2D

const N_DATA = 100				# 入力データ数
const N_NODE = 100				# 中間ノード数

var vec_input = []				# 入力データ配列, [x, y, bool]


# Called when the node enters the scene tree for the first time.
func _ready():
	init()
	pass # Replace with function body.
func init():
	vec_input = []
	for i in range(N_DATA/2):
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
