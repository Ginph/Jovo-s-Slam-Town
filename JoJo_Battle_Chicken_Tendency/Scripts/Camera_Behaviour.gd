#Big thank you too /r/CowThing! Without your help this project would not a working camera

extends Camera2D

var pos_left = 0.0
var pos_right = 0.0
var pos_up = 0.0
var pos_down = 0.0

var border_size = 100
var min_zoom = 0.5


func _ready():
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	scan()
	var box = Rect2(Vector2(pos_left, pos_up),Vector2())
	box = box.expand(Vector2(pos_right, pos_down))
	
	box = box.grow(border_size)
	
	var window_size = OS.get_window_size()
	
	var scale_w = window_size.x / box.size.x
	var scale_h = window_size.y / box.size.y
	var scale = 1 / min(scale_w, scale_h)
	
	scale = max(min_zoom, scale)
	
	set_zoom(Vector2(scale,scale))
	set_pos(Vector2(((pos_left + pos_right) / 2),((pos_up + pos_down) / 2)))
	
	pass

func compare(var pos_cam, var pos_obj, var pos_neg):
	if(pos_neg):
		if(pos_obj > pos_cam):
			pos_cam = pos_obj
			
	elif(pos_neg == false):
		if(pos_obj < pos_cam):
			pos_cam = pos_obj
	return pos_cam
	
func scan():
	var dog
	dog = get_tree().get_nodes_in_group("Player")[0]
	pos_left = dog.get_pos().x
	pos_right = dog.get_pos().x
	pos_up = dog.get_pos().y
	pos_down = dog.get_pos().y
	
	for tree in get_tree().get_nodes_in_group("Player"):
		
		pos_left = compare(pos_left, tree.get_pos().x, false)
		pos_right = compare(pos_right, tree.get_pos().x, true)
		pos_up = compare(pos_up, tree.get_pos().y, false)
		pos_down = compare(pos_down, tree.get_pos().y, true)
		
	pass