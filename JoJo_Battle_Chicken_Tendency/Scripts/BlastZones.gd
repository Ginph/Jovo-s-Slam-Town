extends Node2D

func _ready():
	
	pass

func CheckForPlayer(var body):
	if(body.is_in_group("Player")):
		body.velocity = Vector2(0,0)
		body.stockLoss()
		body._set_state(body.INTRO_STATE)
	pass

func _on_Blast_Zone_Top_body_enter( body ):
	CheckForPlayer(body)
	pass # replace with function body

func _on_Blast_Zone_Bottom_body_enter( body ):
	CheckForPlayer(body)
	pass # replace with function body

func _on_Blast_Zone_Left_body_enter( body ):
	CheckForPlayer(body)
	pass # replace with function body

func _on_Blast_Zone_Right_body_enter( body ):
	CheckForPlayer(body)
	pass # replace with function body
