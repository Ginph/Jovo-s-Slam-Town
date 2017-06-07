extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var state = 0
var level = 0
var backanimations = ["Stage Start" , "Options Panel" , "Credits Panel"]
var level_paths = ["res://Scences/Main.tscn","","","","",""]

func _ready():
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
	get_node("2D/Stage Preview").set_texture("res://Sprite/Lucid City Preview.png")
	level = 0
	pass # replace with function body


func _on_Fight_Button_pressed():
	
	get_tree().change_scene(level_paths[level])
	
	pass # replace with function body
