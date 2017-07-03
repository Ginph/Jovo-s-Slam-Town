extends Node

var state = 0
var level = 0
var backanimations = ["Stage Start" , "Options Panel" , "Credits Panel"]
var level_paths = ["res://Scences/TestStage.tscn","res://Scences/TestStage2.tscn","","","",""]
#row X, collum Y
var cursor = [0,0]
# State [Collum [ Row[0, 0, 0,], Row[0, 0, 0,], Row[0, 0, 0,] ], Collum [ Row[0, 0, 0,], Row[0, 0, 0,], Row[0, 0, 0,] ]]
var buttons = [[["2D/Arena Button"], ["2D/Options Button"], ["2D/Credits Button"]], [["2D/Lucid City Select", "2D/Locked"]]]

func _ready():
	set_process_input(true)
	pass

func _input(event):
	
	if(Input.is_joy_button_pressed(0,JOY_DPAD_DOWN)):
		print("Down")
		change_focus(0, 1)
	elif(Input.is_joy_button_pressed(0,JOY_DPAD_UP)):
		print("Up")
		change_focus(0, -1)
	
	if(Input.is_joy_button_pressed(0,JOY_DPAD_LEFT)):
		print("Left")
		change_focus(-1, 0)
	elif(Input.is_joy_button_pressed(0,JOY_DPAD_RIGHT)):
		print("Right")
		change_focus(1, 0)
	
	if(Input.is_joy_button_pressed(0,JOY_XBOX_A) > 0.5):
		#I can't find another way to do this...
		print(state)
		get_node(buttons[state][cursor[1]][cursor[0]]).emit_signal("pressed")
		cursor = [0,0]
	
	if(Input.is_joy_button_pressed(0,JOY_XBOX_B) > 0.5):
		#I can't find another way to do this...
		cursor = [0,0]
		_on_Back_Button_pressed()
		print(state)
	
	
	pass

func change_focus(var x, var y):
	
	if((cursor[0] + x) < 0):
		cursor[0] = (buttons[state][cursor[1]].size() - 1)
	else:
		cursor[0] = (cursor[0] + x)
		
	if(cursor[0] > (buttons[state][cursor[1]].size() - 1)):
		cursor[0] = 0
		
	if((cursor[1] + y) < 0):
		cursor[1] = (buttons[state].size() - 1)
	else:
		cursor[1] = (cursor[1] + y)
		
	if(cursor[1] > (buttons[state].size() - 1)):
		cursor[1] = 0
	
	print(cursor)
	get_node(buttons[state][cursor[1]][cursor[0]]).grab_focus()
	
	pass

func change_state(var funnumber):
	state = funnumber
	

func _on_Arena_Button_pressed():
	get_node("Animation").play("Stage Start")
	pass # replace with function body

func _on_Options_Button_pressed():
	get_node("Animation").play("Options Panel")
	pass # replace with function body


func _on_Credits_Button_pressed():
	get_node("Animation").play("Credits Panel")
	pass # replace with function body

func _on_Back_Button_pressed():
	get_node("Animation").play_backwards(backanimations[state - 1])
	print((backanimations[state - 1]))
	pass # replace with function body
	


func _on_Lucid_City_Select_pressed():
	get_node("2D/Stage Preview").set_texture(load("res://Sprites/Menu/Lucid City Preview.png"))
	level = 0
	pass # replace with function body


func _on_Locked_pressed():
	get_node("2D/Stage Preview").set_texture(load("res://Sprites/Menu/TestStage2_Preview.png"))
	level = 1
	pass # replace with function body

func _on_Fight_Button_pressed():
	
	get_tree().change_scene(level_paths[level])
	
	pass # replace with function body

