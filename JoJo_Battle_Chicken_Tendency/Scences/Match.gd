extends Node

export var spawnpoints = Vector2Array()

func _ready():
	
	for players in get_tree().get_nodes_in_group("Player"):
		players.set_layer_mask_bit(players.controller, true)
		print(players.get_layer_mask_bit(players.controller))
	
	pass
