extends TextureFrame

export var Who = ""
export var controller = 0


func _ready():

	pass

func search():
	for players in get_tree().get_nodes_in_group("Player"):
		if(players.controller == controller):
			Who = players.get_path()
			set_fixed_process(true)
	pass

func _fixed_process(delta):
	#print("WAAA")
	get_node("Percentage").set_text(String(get_node(Who).damage))
	get_node("Stock").set_text(String(get_node(Who).stocks))
	pass