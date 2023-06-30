extends Node2D

var N_INPUT = 10
var vec_pair = []				# データ配列, 要素：[x, y, bool]
var vec_graph_rect = []

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
	init()
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
	update_graphs()
	pass # Replace with function body.
