extends Node2D


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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_top_button_pressed():
	get_tree().change_scene_to_file("res://top_scene.tscn")
	pass # Replace with function body.
