extends Node

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	
	for players in get_tree().get_nodes_in_group("Player"):
		players.set_layer_mask_bit(players.controller, true)
		print(players.get_layer_mask_bit(players.controller))
	
	pass
