extends Node2D

var timer = 0
var max_time = 25
var direction
var boy

func _ready():
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	
	if(get_node("Particles2D").is_emitting()):
		if(timer > 0):
			timer = (timer - 1)
		else:
			get_node("Particles2D").set_emitting(false)
			boy.stockLoss()
			boy._set_state(boy.INTRO_STATE)
	pass

func CheckForPlayer(var body):
	if(body.is_in_group("Player")):
		get_node("SamplePlayer2D").play("KO")
		body.velocity = Vector2(0,0)
		timer = max_time
		get_node("Particles2D").set_emitting(true)
		get_node("Particles2D").set_pos(body.get_pos())
		#get_node("Particles2D").set_initial_velocity(direction)
		get_node("Particles2D").set_param(0, direction)
		#get_node("Particles2D").set_color(body.flag)

		get_node("Particles2D").get_color_ramp().set_color(0,body.flag)
		get_node("Particles2D").get_color_ramp().set_color(1,body.flag)
		
		boy = body
	pass

func explosion(var direction = 0):
	get_node("Particles2D").set_emitting(true)
	
	
	pass

func _on_Blast_Zone_Top_body_enter( body ):
	direction = 0
	CheckForPlayer(body)
	pass # replace with function body

func _on_Blast_Zone_Bottom_body_enter( body ):
	direction = 180
	CheckForPlayer(body)
	pass # replace with function body

func _on_Blast_Zone_Left_body_enter( body ):
	direction = 90
	CheckForPlayer(body)
	pass # replace with function body

func _on_Blast_Zone_Right_body_enter( body ):
	direction = 270
	CheckForPlayer(body)
	pass # replace with function body
