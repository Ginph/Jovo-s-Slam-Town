extends CanvasLayer

func _ready():
	
	#Get all Players
	
	var num = 0
		
	for players in get_tree().get_nodes_in_group("Player"):
		
		var player_token = load("res://Scences/PlayerToken.tscn").instance()
		get_node("HBoxContainer").add_child(player_token)
		#player_token.set
		player_token.get_node("Background1").set_modulate(players.flag)
		player_token.controller = num
		num += 1
		player_token.search()
		pass

	pass
	
func _fixed_process(delta):
	
	pass
