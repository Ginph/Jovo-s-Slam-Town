extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var state = 0
var backanimations = ["Arena Panel" , "Options Panel" , "Credits Panel"]

func _ready():
	pass

func change_state(var funnumber):
	state = funnumber
	

func _on_Arena_Button_pressed():
	get_node("Animation").play("Arena Panel")
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
	
