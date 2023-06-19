extends Node2D

var pressed_ix = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	#var fnt = $BlackFontLabel.get_theme_font("font")
	$SingleLayerRect.fnt = $BlackFontLabel.get_theme_font("font")
	$SingleLayerRect.queue_redraw()
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
	if point_in_rect($SingleLayerRect, pos): return 0
	if point_in_rect($DoubleLayerRect, pos): return 1
	return -1
func _input(event):
	if event is InputEventMouseButton:
		var mpos = get_global_mouse_position()
		print(mpos)
		var ix = pos_to_index(mpos)		# 
		print(ix)
		if event.is_pressed():
			print("pressed")
			pressed_ix = ix
		else:
			print("released")
			if ix == pressed_ix:
				if ix == 0:
					get_tree().change_scene_to_file("res://fc1layer_scene.tscn")
				elif ix == 1:
					get_tree().change_scene_to_file("res://fc1layer_scene.tscn")
			pressed_ix = -1
	pass

func _on_single_layer_nn_button_pressed():
	get_tree().change_scene_to_file("res://fc2layer_scene.tscn")
	pass # Replace with function body.


func _on_two_layer_nn_button_pressed():
	get_tree().change_scene_to_file("res://fc2layer_scene.tscn")
	pass # Replace with function body.
