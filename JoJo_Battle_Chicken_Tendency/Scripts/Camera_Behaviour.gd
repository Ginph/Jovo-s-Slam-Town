#Big thank you too /r/CowThing! Without your help this project would not a working camera

extends Camera2D

var pos_left = 0.0
var pos_right = 0.0
var pos_up = 0.0
var pos_down = 0.0

export var limit_left = 0
export var limit_right = 0
export var limit_up = 0
export var limit_down = 0

var border_size = 100
var min_zoom = 0.6

var t = 0

func _ready():
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	var dog
	dog = get_tree().get_nodes_in_group("Player")[0]
	pos_left = dog.get_pos().x
	pos_right = dog.get_pos().x
	pos_up = dog.get_pos().y
	pos_down = dog.get_pos().y
	

	for tree in get_tree().get_nodes_in_group("Player"):
	
		pos_left = compare(pos_left, tree.get_pos().x, true)
		pos_right = compare(pos_right, tree.get_pos().x, false) #THIS
		pos_up = compare(pos_up, tree.get_pos().y, true)
		pos_down = compare(pos_down, tree.get_pos().y, false)
	
	
	if(pos_left < limit_left):
		pos_left = limit_left
		
	if(pos_right > limit_right):
		pos_right = limit_right
	
	if(pos_up < limit_up):
		pos_up = limit_up
	
	if(pos_down > limit_down):
		pos_down = limit_down
		
		#Left Up Right Down
	var box = Rect2(Vector2(((pos_left + pos_right) / 2), ((pos_up + pos_down) / 2)),Vector2())
	#box = box.expand(Vector2(pos_right, pos_down))
	#box = box.expand(Vector2(pos_left, pos_up))
	
	#box = box.grow(border_size)
	
	
	var window_size = OS.get_window_size()
	
	var scale_w = (window_size.x / box.size.x)
	var scale_h = (window_size.y / box.size.y)
	var scale = (1 / min(scale_w, scale_h))
	#var scale = min(scale_w, scale_h)
	
	#scale = max(min_zoom, scale)
	
	if((pos_right - pos_left) > (pos_down - pos_up)):
		t = (pos_right - pos_left)
	else:
		t = (pos_down - pos_up)
	
	t = (t * 0.0005)

	window_size = (window_size / 1000)
	
	var u = Vector2()
	
	window_size.x = (1 / window_size.x)
	window_size.y = (1 / window_size.y)
	
	if(window_size.x < window_size.y):
		u = window_size.x
	else:
		u = window_size.y
	
	u = (u + t)
	
	#set_zoom(Vector2(scale,scale))
	set_zoom(Vector2(u,u))
	set_pos(box.pos)
	
	pass

func compare(var pos_cam, var pos_obj, var pos_neg):
	if(pos_neg):
		if(pos_obj < pos_cam):
			return pos_obj
	else:
		if(pos_obj > pos_cam):
			return pos_obj
			
	return pos_cam