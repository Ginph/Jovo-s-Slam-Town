extends "res://Scripts/Player.gd"

const SIDEB_STATE = 17
const AIM_STATE = 18

var hamon_Charge = 0
var clack_speed = 10
var clack_speed_max = 10

var TriggerB = true

func _set_state_extra(new_state):
	#velocity = state.player.velocity
	state.exit()
	
	if(new_state == SIDEB_STATE):
		state = SideB_State.new(self)
	elif(new_state == AIM_STATE):
		state = Aim_State.new(self)
		pass

func _ready():

	#set_fixed_process(true)
	#set_process_input(true)

	pass

func _input(event):
	#state.input(event)
	
	if((event.is_action(Input_Trigger_Left) && TriggerB) || (event.is_action(Input_Trigger_Right) && !TriggerB)):
	
		#Left
		if((event.value > 0.1) && TriggerB):
			clack_speed = (clack_speed - 0.25)
			TriggerB = false
			
		#Right
		elif((event.value > 0.1) && !TriggerB):
			clack_speed = (clack_speed - 0.25)
			TriggerB = true
	
	if(clack_speed < 1):
		clack_speed = 1
		
		
	if(Input.is_action_pressed(Input_A)):
			if(!get_node("Clackers").is_hidden()):
					_set_state_extra(AIM_STATE)
	if(Input.is_action_pressed(Input_B) && (hamon_Charge > 100)):
			_set_state_extra(SIDEB_STATE)
	
	pass

func _fixed_process(delta):

	#state.update(delta)

	size = (10 / clack_speed)

	#Change rotation on Clackers
	var clack_rot = get_node("Clackers").get_rot()
	get_node("Clackers").set_rot(clack_rot + (clack_speed * facing_Right_Num))

	get_node("Clackers/HamonSprite").set_scale(Vector2(size,size))
	
	if(get_node("Clackers/HamonSprite").get_scale().x < 1.25):
		get_node("Clackers/HamonSprite").set_hidden(true)
	else:
		get_node("Clackers/HamonSprite").set_hidden(false)
	
	if(get_node("Clackers/HamonSprite").get_scale().x < 3):
		get_node("Clackers/HamonSprite").set_animation("Hamon_Small")
	else:
		get_node("Clackers/HamonSprite").set_animation("Hamon_Big")
	
	if(clack_speed < clack_speed_max):
		if(_get_state() != AIM_STATE):
			clack_speed += 0.005

	if(_get_state() == RUN_STATE):
		hamon_Charge += 5

	pass

func throw():
	
	if(self.get_node("Clackers").is_visible()):
		get_node("Clackers").set_hidden(true)
	
		#Create new node and change owner value of owner to the player also set velocity of node
		var clacker_scence = load("res://Scences/Clacker.tscn").instance()
		clacker_scence.assingedNumber = controller
		clacker_scence.timer = (12 - clack_speed)
		clacker_scence.get_node("Particles2D").set_color(flag)
		
		get_tree().get_root().add_child(clacker_scence)

		#clacker_scence.get_node("Area2D").set_scale(Vector2((0.25 * size),(0.25 * size)))
		clacker_scence.get_node("Area2D").set_scale(Vector2(size,size))
		
		if(size < 5):
			clacker_scence.get_node("Area2D/Hamon").set_animation("Hamon_Small")
		else:
			clacker_scence.get_node("Area2D/Hamon").set_animation("Hamon_Big")
		#clacker_scence.get_node("Particles2D").set_param(11, size)
		
		clacker_scence.set_global_pos(self.get_global_pos())
		
		var T = Vector2(-sin(get_node("Sprite 2").get_rot()),-cos(get_node("Sprite 2").get_rot()))

		clacker_scence.set_linear_velocity(T * (100 + (clack_speed * 50)))
		clacker_scence.set_angular_velocity(get_node("Clackers").get_rot() + (clack_speed * facing_Right_Num)) #9.8
		
	pass

# SIDEB STATE -------------------------------------------------------

class SideB_State:
	var player
	var joy
	var hit = false

	func _init(player):
		
		self.player = player
		player.get_node("AnimationPlayer").play("Side-B-Dash")
		
		player.velocity = Vector2((player.hamon_Charge * player.facing_Right_Num),0)
		
		pass

	func update(delta):

		#player.Axis = player.axis_Calculator(player.Axis)
		if(!hit):
			if(player.velocity.x < 0.3 && player.velocity.x > -0.3):
				player._set_state(player.FALL_STATE)	
				
			#Check for collision with other player
			if(player.get_node("Area2D").get_overlapping_bodies() != null):
				
				for objects in player.get_node("Area2D").get_overlapping_bodies():
					
					if(objects.is_in_group("Player")):
						player.get_node("AnimationPlayer").play("Side-B-Hit")
						player.velocity = Vector2(0,0)
						objects.set_global_pos(Vector2(objects.get_global_pos().x,(objects.get_global_pos().y - 3)))
						objects.velocity = Vector2(0,-300)
						objects._set_state(player.LAUNCH_STATE)
						player.get_node("SamplePlayer2D").play("Slam")
						
						hit = true
		else:
			if(!player.get_node("AnimationPlayer").is_playing()):
				player._set_state(player.FALL_STATE)

		player.player_physics(Vector2(400, 0), delta,false,120)

	func input(event):

		pass

	func exit():
		player.hamon_Charge = 0
		print("Exit")
		pass
		

# AIM STATE -------------------------------------------------------

class Aim_State:
	var player
	var throw = false

	func _init(player):
		self.player = player

		player.get_node("Sprite 2").set_hidden(false)
		player.get_node("AnimationPlayer").play("Aim")
		pass

	func update(delta):

		player.Axis = player.axis_Calculator(player.Axis)
		
		if(player.Axis.x < 0):
			player.update_side(true)
		elif(player.Axis.x > 0):
			player.update_side(false)
		
		if( !Input.is_action_pressed(player.Input_A) ):
			
			if(!throw):
				if( (player.Axis.x > 0.5) || (player.Axis.x < -0.5) || (player.Axis.y > 0.5) || (player.Axis.y < -0.5)):
					throw = true
					#Why did it take me all day( (3 or 4)+ Hours) ?!?!
					var anim_speed = ((round(player.clack_speed) + (((10 - round(player.clack_speed)) /2))) / 10)
					
					player.get_node("AnimationPlayer").set_speed(anim_speed)
					player.get_node("AnimationPlayer").play("Throw", -1, anim_speed)
				else:
					player.get_node("AnimationPlayer").set_speed(1)
					player._set_state(player.WALK_STATE)
					
			else:
				if(!player.get_node("AnimationPlayer").is_playing()):
					player.throw()
					player._set_state(player.WALK_STATE)
			
		player.player_physics(Vector2(400, 150), delta,false,120)
		
		pass

	func input(event):
		
		if(!throw):
			player.get_node("Sprite 2").set_rot(atan2(player.Axis.x, player.Axis.y))
		
		pass

	func exit():
		player.get_node("AnimationPlayer").set_speed(1)
		player.get_node("Sprite 2").set_hidden(true)
		pass

