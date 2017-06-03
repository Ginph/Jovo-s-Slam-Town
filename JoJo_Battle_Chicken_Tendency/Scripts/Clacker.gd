extends RigidBody2D

export var assingedNumber = 0
var PlayerOBJ
var timer = 1
	
func _ready():
	# Called every time the node is added to the scene.
	
	#Scan for Player with controller number that matches assigned number
	if(assingedNumber > -1 && assingedNumber < 9):
		for player in get_tree().get_nodes_in_group("Player"):
			if(player.controller == assingedNumber):
				PlayerOBJ = player
			print(player.controller)
			
	#Check if the obj is empty
	if(PlayerOBJ != null):
		#self.set_pos(PlayerOBJ.get_global_pos())
		set_fixed_process(true)
		self.get_node("Clacker_Sprite").set_modulate(PlayerOBJ.flag)
		
	pass

func _fixed_process(delta):
	#print(self.get_global_pos())
	var rotae = self.get_angular_velocity()
	
	if(rotae > 1):
		self.get_node("Clacker_Sprite").set_texture(load("res://Characters/Joshep/Sprites/Clackers/Clackers3_1.png"))
	else:
		self.get_node("Clacker_Sprite").set_texture(load("res://Characters/Joshep/Sprites/Clackers/clackers2_2.png"))

	timer -= delta
	
	if(timer <= 0):
		PlayerOBJ.clack_speed = PlayerOBJ.clack_speed_max
		PlayerOBJ.get_node("Clackers").set_hidden(false)
		self.queue_free()
	
	pass