extends Node2D

const N_INPUT = 40
var pressed_ix = -1
var rect_lst = []

# Called when the node enters the scene tree for the first time.
func _ready():
	rect_lst.push_back($SingleLayerRect)
	rect_lst.push_back($DoubleLayerRect)
	rect_lst.push_back($TripleLayerRect)
	rect_lst.push_back($ActivationDistriRect)
	#var fnt = $BlackFontLabel.get_theme_font("font")
	#$SingleLayerRect.fnt = $BlackFontLabel.get_theme_font("font")
	#$SingleLayerRect.queue_redraw()
	var vec_pair = []
	for i in range(N_INPUT/2):
		var x = randfn(0.0, 1.0)
		var y = randfn(0.0, 1.0)
		vec_pair.push_back([x, y, false])
	$ActivationDistriRect/GraphRect.vec_input = vec_pair
	$ActivationDistriRect/GraphRect.maxv = 3.0
	$ActivationDistriRect/GraphRect.to_draw_div_lines = false
	$ActivationDistriRect/GraphRect.to_plot_boolean = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func point_in_rect(ctrl: Control, pnt: Vector2) -> bool:
	var pos = ctrl.position
	var sz = ctrl.size
	return (pnt.x >= pos.x && pnt.x < pos.x + sz.x &&
			pnt.y >= pos.y && pnt.y < pos.y + sz.y)
func pos_to_index(pos):
	#if point_in_rect($SingleLayerRect, pos): return 0
	#if point_in_rect($DoubleLayerRect, pos): return 1
	for i in range(rect_lst.size()):
		if point_in_rect(rect_lst[i], pos): return i
	return -1
func clear_selected():
	for i in range(rect_lst.size()):
		rect_lst[i].selected = false
		rect_lst[i].queue_redraw()
func _input(event):
	if event is InputEventMouseButton:
		var mpos = get_global_mouse_position()
		print(mpos)
		var ix = pos_to_index(mpos)		# 
		print(ix)
		if ix >= 0:
			if event.is_pressed():
				print("pressed")
				pressed_ix = ix
				rect_lst[ix].selected = true
				rect_lst[ix].queue_redraw()
			else:
				print("released")
				if ix == pressed_ix:
					do_change_scene(ix)
				pressed_ix = -1
				clear_selected()
		else:
			clear_selected()
	pass

func do_change_scene(ix):
	if ix == 0:
		get_tree().change_scene_to_file("res://fc1layer_scene.tscn")
	elif ix == 1:
		get_tree().change_scene_to_file("res://fc2layer_scene.tscn")
	elif ix == 2:
		get_tree().change_scene_to_file("res://fc3layer_scene.tscn")
	elif ix == 3:
		get_tree().change_scene_to_file("res://activate_distri_scene.tscn")
	
func _on_single_layer_nn_button_pressed():
	do_change_scene(0)
	pass # Replace with function body.
func _on_two_layer_nn_button_pressed():
	do_change_scene(1)
	pass # Replace with function body.
func _on_activate_distri_button_pressed():
	do_change_scene(2)
	pass # Replace with function body.
