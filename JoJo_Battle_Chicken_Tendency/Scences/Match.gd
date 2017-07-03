extends Node

export var spawnpoints = Vector2Array()
export var team_num = []
var stage = 0

func _ready():
	
	#Read an array that contains each character selected and pallet and what team they are on
	#Spawn them
	
	
	for players in get_tree().get_nodes_in_group("Player"):
		players.set_layer_mask_bit(players.controller, true)
		print(players.get_layer_mask_bit(players.controller))
	
	check_for_win()
	get_node("Anouncer").play("321Go")
	
	set_fixed_process(true)
	
	pass
	
func _fixed_process(delta):
	
	#var u = 300
	
	#if((get_node("SamplePlayer2D").is_voice_active(0) == false) && stage == 1):
	#	print("OOog")
	#	get_node("SamplePlayer2D").play("P1", 0)
	#	print(get_node("SamplePlayer2D").is_voice_active(0))
	#	stage = 2
	#if((get_node("SamplePlayer2D").is_voice_active(0) == false) && stage == 2):
		#print("AHHH")
		#print(get_node("SamplePlayer2D").is_voice_active(0))
		#get_node("SamplePlayer2D").play("defeated")
		#stage = 0
	
	
	pass
	
func defeated_voice(var i):
	#var u = 300
	
	#while(u > 0):
		
	#	if(!get_node("SamplePlayer2D").is_playing()):
	#		print("Good")
		
	#	u -= 1
	
	pass

func check_for_win():
	var i = 0
	
	while(i < team_num.size()):
		team_num[i] = 0
		print(team_num, i)
		i = (i + 1)
		
	#var thegoodteam = -1
	#var thegoodteam_count = 0
	#for players in get_tree().get_nodes_in_group("Player"):
	#	team_num[players.team] += players.stocks
	#	print(team_num[players.team])
	#	if(team_num[players.team] > 0):
	#		thegoodteam = players.team
	#		thegoodteam_count += 1
	
	#if(thegoodteam_count == 1):
	#	thegoodteam
		
	var thegoodteam = -1
	var thegoodteam_count = 0
	var V = -1
	for players in get_tree().get_nodes_in_group("Player"):
		team_num[players.team] += players.stocks

		if(players.stocks <= 0):
			players.remove_from_group("Player")
			players.set_hidden(true)
			check_for_win()
			
		print(team_num[players.team])
		if(team_num[players.team] != V):
			thegoodteam_count += 1
			thegoodteam = players.team
			
	if(thegoodteam_count == 1):
		#defeated_voice(thegoodteam)
		
		for players in get_tree().get_nodes_in_group("Player"):
			if(players.team == thegoodteam):
				print("Works")
				get_node("gui/Go/Sprite").set_modulate(players.flag)
		
		get_node("gui/Go/AnimationPlayer").play("WinnerAni")
		
	pass