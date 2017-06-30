extends KinematicBody2D

export var controller = 0 #This defines what controller the character belongs to
export var flag = Color() #This is the colour that is used to represent who is on what team
export var team = 0 

const gravity = 300
var velocity = Vector2()
var max_fall_velocity = 10
var max_air_velocity = 5
var raycast_left
var raycast_right
var raycast_side
var spawn_point
var grounded = false
var leaned = false

var Axis = Vector2(0,0) #This stores how where your controller anolog is

var previous_axis #This is gonna be used to figure out how fast you are moving the joy stick
var cstick_p = Vector2(0,0) #This stores how where your controller second anolog is
var ran = false

var facing_Right = true
var facing_Right_Num = 1 # Left = -1 Right = 1

const IDLE_STATE = 0
const TAUNT_STATE = 1
const FALL_STATE = 2
const WALK_STATE = 3
const LAND_STATE = 4
const JUMP_STATE = 5
const CROUCH_STATE = 6
const PREJUMP_STATE = 7
const LEAN_STATE = 8
const RUN_STATE = 9
const SLIDE_STATE = 10
const TURN_STATE = 11
const RUNNINGTURN_STATE = 13
const DASH_STATE = 14
const WALLSLIDE_STATE = 15
const LAUNCH_STATE = 16
const SIDEB_STATE = 17
const AIM_STATE = 18
const INTRO_STATE = 19

#Control Name Variables
export var Input_Up = " "
export var Input_Down = " "
export var Input_Left = " "
export var Input_Right = " "

export var Input_Jump = " "
export var Input_B = " "
export var Input_A = " "

export var Input_Taunt_Up = " "
export var Input_Taunt_Down = " "

export var Input_Trigger_Left = " "
export var Input_Trigger_Right = " "

export var Input_C_Left = " "
export var Input_C_Right = " "
export var Input_C_Up = " "
export var Input_C_Down = " "

var walk_Speed = 600
var max_walk_speed = 100
var jump_count = 2

var jump_Type = false #false = regular jump | True = WallJump

var damage = 0
var stocks = 3

var hamon_Charge = 0
var clack_speed = 10
var clack_speed_max = 10
var size = 1
var TriggerB = true

var taunt = 0
var taunt_list = ["Taunt_Pose" , "Taunt_BM"]

onready var state = Fall_State.new(self)

func _ready():

	raycast_left = get_node("RayCast_Left")
	raycast_right = get_node("RayCast_Right")
	raycast_side = get_node("RayCast_Side")

	#This is done so the raycasts do not count the player itself when detecting for collision
	raycast_left.add_exception(self)
	raycast_right.add_exception(self)
	raycast_side.add_exception(self)
	
	self.get_node("Sprite").set_modulate(flag)
	self.get_node("Clackers").set_modulate(flag)
	
	get_node("Area2D").set_collision_mask_bit(controller, false)

	_set_state(INTRO_STATE)

	set_fixed_process(true)
	set_process_input(true)
	
	pass

func _fixed_process(delta):

	state.update(delta)

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

	pass

func _input(event):
	state.input(event)
	
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
	
	#C stick previous
	cstick_p = axis_c_Calculator()
	
	pass

func _set_state(new_state):
	#velocity = state.player.velocity
	state.exit()

	if(new_state == IDLE_STATE):
		state = Idle_State.new(self)
	elif(new_state == TAUNT_STATE):
		state = Taunt_State.new(self)
	elif(new_state == FALL_STATE):
		state = Fall_State.new(self)
	elif(new_state == WALK_STATE):
		state = Walk_State.new(self)
	elif(new_state == LAND_STATE):
		state = Land_State.new(self)
	elif(new_state == JUMP_STATE):
		state = Jump_State.new(self)
	elif(new_state == CROUCH_STATE):
		state = Crouch_State.new(self)
	elif(new_state == PREJUMP_STATE):
		state = PreJump_State.new(self)
	elif(new_state == LEAN_STATE):
		state = Lean_State.new(self)
	elif(new_state == RUN_STATE):
		state = Run_State.new(self)
	elif(new_state == SLIDE_STATE):
		state = Slide_State.new(self)
	elif(new_state == TURN_STATE):
		state = Turn_State.new(self)
	elif(new_state == RUNNINGTURN_STATE):
		state = RunningTurn_State.new(self)
	elif(new_state == DASH_STATE):
		state = Dash_State.new(self)
	elif(new_state == WALLSLIDE_STATE):
		state = WallSlide_State.new(self)
	elif(new_state == LAUNCH_STATE):
		state = Launch_State.new(self)
	elif(new_state == SIDEB_STATE):
		state = SideB_State.new(self)
	elif(new_state == AIM_STATE):
		state = Aim_State.new(self)
	elif(new_state == INTRO_STATE):
		state = Intro_State.new(self)
		pass

func _get_state():
	if(state extends Idle_State):
		return IDLE_STATE
	elif(state extends Taunt_State):
		return TAUNT_STATE
	elif(state extends Fall_State):
		return FALL_STATE
	elif(state extends Walk_State):
		return WALK_STATE
	elif(state extends Land_State):
		return LAND_STATE
	elif(state extends Jump_State):
		return JUMP_STATE
	elif(state extends Crouch_State):
		return CROUCH_STATE
	elif(state extends PreJump_State):
		return PREJUMP_STATE
	elif(state extends Lean_State):
		return LEAN_STATE
	elif(state extends Run_State):
		return RUN_STATE
	elif(state extends Slide_State):
		return SLIDE_STATE
	elif(state extends Turn_State):
		return TURN_STATE
	elif(state extends RunningTurn_State):
		return RUNNINGTURN_STATE
	elif(state extends Dash_State):
		return DASH_STATE
	elif(state extends WallSlide_State):
		return WALLSLIDE_STATE
	elif(state extends Launch_State):
		return LAUNCH_STATE
	elif(state extends Aim_State):
		return AIM_STATE
	elif(state extends Intro_State):
		return INTRO_STATE
	pass

func player_physics(var speed, delta, var input, var friction):

	var force = Vector2(0, speed.y)
	#speed = Vector2()
	var o

	o = axis_Calculator(o)

	if(( input && ((o.x > 0.5 ) || (o.x < -0.5)) && velocity.x < max_walk_speed && velocity.x > -max_walk_speed )):
		force.x += ((o.x) * speed.x)

	else:
		var vsigh = sign(velocity.x)
		var vlen = abs(velocity.x)

		vlen -= friction*delta

		if(vlen < 0):
			vlen = 0

		velocity.x = vsigh*vlen

	velocity += force*delta

	var motion = velocity*delta

	motion = move(motion)

	var floor_velocity = Vector2();

	if(Axis.y > 0.6):
		if(_get_state() != AIM_STATE):
			self.set_collision_mask_bit(11, false)
		
	else:
		self.set_collision_mask_bit(11, true)
		

	if (is_colliding()):		

		var n = get_collision_normal()
		var sides_value = rad2deg(acos(n.dot(Vector2(-1, 0))))

		if(_get_state() == LAUNCH_STATE):
			velocity = n.reflect(velocity)
			get_node("SamplePlayer2D").play("Slam")
		
		if(rad2deg(acos(n.dot(Vector2(0, -1)))) < 40):
			floor_velocity = get_collider_velocity()
		else:

			if(_get_state() != LAUNCH_STATE):
				if(!raycast_left.is_colliding() && !raycast_right.is_colliding()):
					#Check for Left
					if(raycast_side.is_colliding()):
						if(Axis.x < -0.5 && sides_value == 180):
							update_side(false)
							_set_state(WALLSLIDE_STATE)
					#Check for Right
						if(Axis.x > 0.5 && sides_value == 0):
							#print("Right")
							update_side(true)
							_set_state(WALLSLIDE_STATE)

		if(force.x == 0 and get_travel().length() < 1 and abs(velocity.x) < 1 and get_collider_velocity() == Vector2()):
			revert_motion()
			velocity.y = 0.0
		else:
			motion = n.slide(motion)
			
			if(_get_state() != LAUNCH_STATE):
				velocity = n.slide(velocity)

			move(motion)

	if(floor_velocity != Vector2()):
		move(floor_velocity)

	pass

func axis_Calculator(var p):
	p = Vector2(Input.get_joy_axis(controller,JOY_AXIS_0), Input.get_joy_axis(controller,JOY_AXIS_1))

	if(Input.is_action_pressed(Input_Left)):
		p.x = -1
	elif(Input.is_action_pressed(Input_Right)):
		p.x = 1
	elif(Input.get_joy_axis(controller,JOY_AXIS_0) < 0.2 && Input.get_joy_axis(controller,JOY_AXIS_0) > -0.2):
		p.x = 0

	if(Input.is_action_pressed(Input_Up)):
		p.y = -1
	elif(Input.is_action_pressed(Input_Down)):
		p.y = 1
	elif(Input.get_joy_axis(controller,JOY_AXIS_1) < 0.2 && Input.get_joy_axis(controller,JOY_AXIS_1) > -0.2):
		p.y = 0

	if(previous_axis != null):
		if(((p.x - previous_axis.x) > 0.4) || ((p.x - previous_axis.x) < -0.4)):
			ran = true
		#Why was this commented out?
		#else:
			#ran = false

	previous_axis = p

	return p

func axis_c_Calculator():
	
	var p = Vector2(Input.get_joy_axis(controller,JOY_AXIS_2), Input.get_joy_axis(controller,JOY_AXIS_3))
	
	if(Input.is_action_pressed(Input_C_Left)):
		p.x = -1;
	elif(Input.is_action_pressed(Input_C_Right)):
		p.x = 1
	elif(Input.get_joy_axis(controller,JOY_AXIS_2) < 0.2 && Input.get_joy_axis(controller,JOY_AXIS_2) > -0.2):
		p.x = 0
		
	if(Input.is_action_pressed(Input_C_Up)):
		p.y = -1
	elif(Input.is_action_pressed(Input_C_Down)):
		p.y = 1
	elif(Input.get_joy_axis(controller,JOY_AXIS_3) < 0.2 && Input.get_joy_axis(controller,JOY_AXIS_3) > -0.2):
		p.y = 0
	
	return p

func flip():
	update_side(!facing_Right)
	pass

func check_lean():
	if(!facing_Right):
		if((!get_node("RayCast_Middle").is_colliding() && get_node("RayCast_Right").is_colliding()) && !leaned):
			leaned = true
			_set_state(LEAN_STATE)
	else:
		if((!get_node("RayCast_Middle").is_colliding() && get_node("RayCast_Left").is_colliding()) && !leaned):
			leaned = true
			_set_state(LEAN_STATE)
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

#func _on_Area2D_body_enter( body ):
	#pass # replace with function body

func _on_Area2D_area_enter( area ):

	if(area.is_in_group("Hurt")):
		if(area.get_owner().assingedNumber != controller):
			damage += round((area.get_owner().get_node("Area2D").get_scale().x * 2))
			#velocity = (area.get_owner().get_linear_velocity() * (damage / area.get_owner().get_node("Clacker_Sprite").get_scale().x))
			set_pos(Vector2(get_pos().x,(get_pos().y - 3)))
			velocity = (((area.get_owner().get_linear_velocity().normalized() * 10) * damage) )
			_set_state(LAUNCH_STATE)

	pass # replace with function body

func stockLoss():
	
	damage = 0
	stocks -= 1
	
	get_tree().get_root().get_node("Node").check_for_win()
	
	pass

func randomize_sounds(var node = "", var names = []):
	
	randomize() #Randomizes the seed that randi() uses
	var num = randi()%names.size()
	print(names.size(), " " , num, " ", names[num])
	get_node(node).play(names[num])
	
	pass
	

func play_sound(var name = "", var node = ""):
	get_node(node).play(name)
	pass

func update_side(side):
	
	facing_Right = side
	get_node("Sprite").set_flip_h(!facing_Right)

	if(facing_Right):
		facing_Right_Num = 1
		raycast_side.set_cast_to(Vector2((facing_Right_Num * 5),0))
		raycast_side.set_pos(Vector2((facing_Right_Num * 9),0))
	else:
		facing_Right_Num = -1
		raycast_side.set_cast_to(Vector2((facing_Right_Num * 5),0))
		raycast_side.set_pos(Vector2((facing_Right_Num * 9),0))
		
	pass

# IDLE STATE -------------------------------------------------------

class Idle_State:
	var player;

	func _init(player):
		self.player = player

		#print("Idle")

		player.ran = false

		player.get_node("AnimationPlayer").play("Idle")
		pass

	func update(delta):

		player.Axis = player.axis_Calculator(player.Axis)

		if(player.leaned == true):
			if(player.get_node("RayCast_Middle").is_colliding()):
				player.leaned = false

		if((player.Axis.x > 0.3 && !player.facing_Right) || (player.Axis.x < -0.3 && player.facing_Right)):
			player._set_state(player.TURN_STATE)
			pass

		if((player.Axis.x > 0.3 && player.facing_Right) || (player.Axis.x < -0.3 && !player.facing_Right)):
			if(player.ran):
				player._set_state(player.DASH_STATE)
			elif(player.ran == false):
				player._set_state(player.WALK_STATE)

		if(player.Axis.y > 0.5):
			player._set_state(player.CROUCH_STATE)

		player.player_physics(Vector2(400, 300),delta,true,120)

		player.check_lean()

		if(!player.get_node("RayCast_Middle").is_colliding() && !player.get_node("RayCast_Left").is_colliding() && !player.get_node("RayCast_Right").is_colliding()):
			player.jump_count = 1
			player._set_state(player.FALL_STATE)
		
		if(Input.is_action_pressed(player.Input_B) && (player.hamon_Charge > 100)):
			if(player.Axis.x > 0.5):
				player.update_side(true)
			elif(player.Axis.x < -0.5):
				player.update_side(false)
				
			player._set_state(player.SIDEB_STATE)

		pass

	func input(event):
		if(Input.is_joy_button_pressed(player.controller, JOY_XBOX_Y) || Input.is_action_pressed(player.Input_Jump)):
			player._set_state(player.PREJUMP_STATE)
			
		if(Input.is_action_pressed(player.Input_A)):
			if(!player.get_node("Clackers").is_hidden()):
				player._set_state(player.AIM_STATE)
				
		if(Input.is_action_pressed(player.Input_Taunt_Up)):
			player.taunt = 0
			player._set_state(player.TAUNT_STATE)
		if(Input.is_action_pressed(player.Input_Taunt_Down)):
			player.taunt = 1
			player._set_state(player.TAUNT_STATE)		
			
		pass

	func exit():
		pass


# TAUNT STATE -------------------------------------------------------

class Taunt_State:
	var player

	func _init(player):
		self.player = player
		player.get_node("AnimationPlayer").play(player.taunt_list[player.taunt])
		pass

	func update(delta):
		if(!player.get_node("AnimationPlayer").is_playing()):
			player._set_state(player.IDLE_STATE)
		pass

	func input(event):
		pass

	func exit():
		pass

# FALL STATE -------------------------------------------------------

class Fall_State:
	var player
	var joy

	func _init(player):
		self.player = player

		#print("Fall")

		player.get_node("AnimationPlayer").play("Fall")
		pass

	func update(delta):

		player.Axis = player.axis_Calculator(player.Axis)

		if((Input.is_joy_button_pressed(player.controller, JOY_XBOX_Y) || Input.is_action_pressed(player.Input_Jump)) && player.jump_count > 0):
			player._set_state(player.JUMP_STATE)

		if(player.get_node("RayCast_Middle").is_colliding()):
			player._set_state(player.LAND_STATE)
		else:
			player.player_physics(Vector2(400, 300), delta,true,120)

		#Fast Fall
		if(player.Axis.y > 0.5):
			player.velocity.y = 300
			
		if(Input.is_action_pressed(player.Input_B) && (player.hamon_Charge > 100)):
			if(player.Axis.x > 0.5):
				player.update_side(true)
			elif(player.Axis.x < -0.5):
				player.update_side(false)
				
			player._set_state(player.SIDEB_STATE)

	func input(event):
		
		if(Input.is_action_pressed(player.Input_A)):
			if(!player.get_node("Clackers").is_hidden()):
					player._set_state(player.AIM_STATE)
		
		pass

	func exit():
		pass

# WALK STATE -------------------------------------------------------

class Walk_State:
	var player
	var b

	func _init(player):
		self.player = player

		#print("Walk")

		player.get_node("AnimationPlayer").play("Walk")
		pass

	func update(delta):

		player.Axis = player.axis_Calculator(player.Axis)

		if(player.leaned == true):
			if(player.get_node("RayCast_Middle").is_colliding()):
				player.leaned = false

		if((player.Axis.x < 0.25) && (player.Axis.x > -0.25)):
			player._set_state(player.IDLE_STATE);

		player.check_lean()

		player.player_physics(Vector2(100, 300), delta, true,120)

		if(!player.get_node("RayCast_Middle").is_colliding() && !player.get_node("RayCast_Left").is_colliding() && !player.get_node("RayCast_Right").is_colliding()):
			player.jump_count = 1
			player._set_state(player.FALL_STATE)

		if(Input.is_action_pressed(player.Input_B) && (player.hamon_Charge > 100)):
			player._set_state(player.SIDEB_STATE)

		pass

	func input(event):
		if((Input.is_action_pressed(player.Input_Jump)) ||Input.is_joy_button_pressed(player.controller, JOY_XBOX_Y)):
			player._set_state(player.PREJUMP_STATE)
		if((Input.is_action_pressed(player.Input_Down)) || (player.Axis.y > 0.5)):
			player._set_state(player.CROUCH_STATE)

		if(Input.is_action_pressed(player.Input_A)):
			if(!player.get_node("Clackers").is_hidden()):
				player._set_state(player.AIM_STATE)

		pass

	func exit():
		pass


# JUMP STATE -------------------------------------------------------

class Jump_State:
	var player

	func _init(player):
		self.player = player

		player.get_node("RayCast_Left").set_enabled(false)

		if(!player.jump_Type):
			player.jump_count -= 1
			player.velocity.x += ((player.Axis.x) * 5)
			player.velocity.y = -200
						
			player.get_node("Vocals").play("Jump")
						
			if(((player.Axis.x < -0.1) && player.facing_Right) || ((player.Axis.x > 0.1) && (player.facing_Right == false))):
				if(player.jump_count == 1):
					player.get_node("Sprite").set_texture(load("res://Characters/Joshep/CompetitiveColours/CoCo_Fallback.png"))
				elif(player.jump_count == 0):
					player.velocity.x = (player.velocity.x + (-player.facing_Right_Num * 30))
					player.get_node("AnimationPlayer").play("Jump_Backwards_2")
			else:
				if(player.jump_count == 1):
					player.get_node("Sprite").set_texture(load("res://Characters/Joshep/CompetitiveColours/CoCo_Spin_1.png"))
				elif(player.jump_count == 0):
					player.get_node("AnimationPlayer").play("Jump2")
						
			#print("Jump")
		else:
			player.get_node("AnimationPlayer").play("WallJump")
			player.velocity = Vector2((player.facing_Right_Num * 150), -250)
			player.jump_Type = false
			#print("WallJump")

		player.hamon_Charge += 5

		pass

	func update(delta):

		player.Axis = player.axis_Calculator(player.Axis)

		if(player.velocity.y >= 0):
			player.get_node("RayCast_Left").set_enabled(true)
			player._set_state(player.FALL_STATE);
		player.player_physics(Vector2(400, 300),delta,true,120)
		
		if(Input.is_action_pressed(player.Input_B) && (player.hamon_Charge > 100)):
			if(player.Axis.x > 0.5):
				player.update_side(true)
			elif(player.Axis.x < -0.5):
				player.update_side(false)
				
			player._set_state(player.SIDEB_STATE)
		
		pass

	func input(event):
		if((Input.is_joy_button_pressed(player.controller, JOY_XBOX_Y) || Input.is_action_pressed(player.Input_Jump)) && player.jump_count > 0):
			player._set_state(player.JUMP_STATE)
			
		if(Input.is_action_pressed(player.Input_A)):
			if(!player.get_node("Clackers").is_hidden()):
				player._set_state(player.AIM_STATE)
			
		pass

	func exit():
		player.get_node("Sprite").set_rot(0)
		pass

# LAND STATE -------------------------------------------------------

class Land_State:
	var player
	var frames

	func _init(player):
		self.player = player

		player.jump_count = 2

		#print("Land")
		
		player.get_node("AnimationPlayer").play("Land")
		pass

	func update(delta):
		
		if(!player.get_node("AnimationPlayer").is_playing()):
			player._set_state(player.IDLE_STATE)
		player.player_physics(Vector2(400, 300),delta,false,120)
		pass

	func input(event):
		pass

	func exit():
		pass

# TURN STATE -------------------------------------------------------

class Turn_State:
	var player

	func _init(player):
		self.player = player
		
		#print("Turn")
		player.get_node("AnimationPlayer").play("Turn")
		pass

	func update(delta):
		
		pass

	func input(event):
		pass

	func exit():
		pass

# CROUCH STATE -------------------------------------------------------

class Crouch_State:
	var player

	func _init(player):
		self.player = player
		#print("Crouch")
		player.get_node("AnimationPlayer").play("Crouch")
		pass

	func update(delta):
		player.Axis = player.axis_Calculator(player.Axis)

		player.player_physics(Vector2(400, 300),delta,false,540)

		if(player.Axis.y < 0.2):
			player._set_state(player.IDLE_STATE)

		pass

	func input(event):
		pass

	func exit():
		pass

# PREJUMP STATE -------------------------------------------------------

class PreJump_State:
	var player

	func _init(player):
		self.player = player
		#print("PreJump")
		player.get_node("AnimationPlayer").play("PreJump")
		pass

	func update(delta):
		if(!player.get_node("AnimationPlayer").is_playing()):
			player._set_state(player.JUMP_STATE)
		player.player_physics(Vector2(400, 300), delta, false,120)
		pass

	func input(event):
		pass

	func exit():
		pass


# LEAN STATE -------------------------------------------------------

class Lean_State:
	var player

	func _init(player):
		self.player = player
		#print("Lean")

		#Does melee have this? Cause I don't think it does.
		player.velocity.x = 0
		player.velocity.y = 0

		player.get_node("AnimationPlayer").play("Lean")
		pass

	func update(delta):

		player.Axis = player.axis_Calculator(player.Axis)

		if( (player.Axis.x > 0.5) || (player.Axis.x < -0.5) ):
			player._set_state(player.WALK_STATE)
		pass

	func input(event):
		pass

	func exit():
		pass


# RUN STATE -------------------------------------------------------

class Run_State:
	var player
	var b

	func _init(player):
		self.player = player

		#print("Run")

		player.get_node("AnimationPlayer").play("Run")
		pass

	func update(delta):

		player.Axis = player.axis_Calculator(player.Axis)

		if(player.Axis.x > 0.3 && !player.facing_Right):
			player._set_state(player.RUNNINGTURN_STATE);

		elif(player.Axis.x < -0.3 && player.facing_Right):
			player._set_state(player.RUNNINGTURN_STATE);

		if(player.leaned == true):
			if(player.get_node("RayCast_Middle").is_colliding()):
				player.leaned = false

		if((player.Axis.x < 0.5) && (player.Axis.x > -0.5)):
			player._set_state(player.SLIDE_STATE);

		player.check_lean()

		player.player_physics(Vector2(600, 300), delta, true,120)

		if(!player.get_node("RayCast_Middle").is_colliding() && !player.get_node("RayCast_Left").is_colliding() && !player.get_node("RayCast_Right").is_colliding()):
			player.jump_count = 1
			player._set_state(player.FALL_STATE)

		#TODO Sort Everything into the correct function like Input & Fixed_Procces
		player.hamon_Charge += 1

		if(Input.is_action_pressed(player.Input_B) && (player.hamon_Charge > 100)):
			player._set_state(player.SIDEB_STATE)

		pass

	func input(event):
		if((Input.is_action_pressed(player.Input_Jump)) ||Input.is_joy_button_pressed(player.controller, JOY_XBOX_Y)):
			player._set_state(player.PREJUMP_STATE)
		if((Input.is_action_pressed(player.Input_Down)) || (player.Axis.y > 0.5)):
			player._set_state(player.CROUCH_STATE)

		pass

	func exit():
		pass

#This might be unnescisary
# SLIDE STATE -------------------------------------------------------

class Slide_State:
	var player
	var b

	func _init(player):
		self.player = player

		#print("Slide")

		player.get_node("AnimationPlayer").play("Slide")

		pass

	func update(delta):

		player.Axis = player.axis_Calculator(player.Axis)

		if(player.leaned == true):
			if(player.get_node("RayCast_Middle").is_colliding()):
				player.leaned = false

		if(player.velocity.x < 0.1 && player.velocity.x > -0.1):
			player._set_state(player.IDLE_STATE);

		if(player.facing_Right && player.Axis.x < -0.7):
			player.update_side(!player.facing_Right)
			player._set_state(player.RUN_STATE);

		elif(!player.facing_Right && player.Axis.x > 0.7):
			player.update_side(!player.facing_Right)
			player._set_state(player.RUN_STATE);

		player.check_lean()

		player.player_physics(Vector2(400, 300), delta, false,120)

		if(!player.get_node("RayCast_Middle").is_colliding() && !player.get_node("RayCast_Left").is_colliding() && !player.get_node("RayCast_Right").is_colliding()):
			player.jump_count = 1
			player._set_state(player.FALL_STATE)

		pass

	func input(event):
		if((Input.is_action_pressed(player.Input_Jump)) ||Input.is_joy_button_pressed(player.controller, JOY_XBOX_Y)):
			player._set_state(player.PREJUMP_STATE)
		if((Input.is_action_pressed(player.Input_Down)) || (player.Axis.y > 0.5)):
			player._set_state(player.CROUCH_STATE)

		pass

	func exit():
		pass

# TURN STATE -------------------------------------------------------

class Turn_State:
	var player
	var b

	func _init(player):
		self.player = player

		#print("Turn")

		if(player.ran):
			player.get_node("AnimationPlayer").set_speed(1.8)
			player.get_node("AnimationPlayer").play("Turn")
		else:
			player.get_node("AnimationPlayer").set_speed(1)
			player.get_node("AnimationPlayer").play("Turn")


		pass

	func update(delta):

		player.Axis = player.axis_Calculator(player.Axis)

		if(!player.get_node("AnimationPlayer").is_playing()):
			if(player.ran):
				player._set_state(player.DASH_STATE)
			else:
				player._set_state(player.IDLE_STATE)

		if(player.leaned == true):
			if(player.get_node("RayCast_Middle").is_colliding()):
				player.leaned = false

		player.check_lean()

		player.player_physics(Vector2(400, 300), delta, false,120)

		if(!player.get_node("RayCast_Middle").is_colliding() && !player.get_node("RayCast_Left").is_colliding() && !player.get_node("RayCast_Right").is_colliding()):
			player.jump_count = 1
			player._set_state(player.FALL_STATE)

		pass

	func input(event):
		if((Input.is_action_pressed(player.Input_Jump)) ||Input.is_joy_button_pressed(player.controller, JOY_XBOX_Y)):
			player._set_state(player.PREJUMP_STATE)
		#if((Input.is_action_pressed("Player1_Down")) || (Input.get_joy_axis(player.controller, JOY_AXIS_1) > 0.5)):
			#player._set_state(player.CROUCH_STATE)

		pass

	func exit():
		pass

#The beggining of the run
# DASH STATE -------------------------------------------------------

class Dash_State:
	var player

	func _init(player):
		self.player = player

		#print("Dash")

		player.get_node("AnimationPlayer").play("Dash")

		if(player.facing_Right):
			player.velocity.x = 200
		else:
			player.velocity.x = -200

		pass

	func update(delta):

		player.Axis = player.axis_Calculator(player.Axis)

		if(!player.get_node("AnimationPlayer").is_playing()):
				player._set_state(player.RUN_STATE)

		if(player.Axis.x < -0.3 && player.facing_Right && player.ran):
			player.update_side(!player.facing_Right)
			player._set_state(player.DASH_STATE)
			pass
		elif(player.Axis.x > 0.3 && !player.facing_Right && player.ran):
			player.update_side(!player.facing_Right)
			player._set_state(player.DASH_STATE)
			pass

		if(player.leaned == true):
			if(player.get_node("RayCast_Middle").is_colliding()):
				player.leaned = false



		player.check_lean()

		player.player_physics(Vector2(400, 300), delta, false,120)

		if(!player.get_node("RayCast_Middle").is_colliding() && !player.get_node("RayCast_Left").is_colliding() && !player.get_node("RayCast_Right").is_colliding()):
			player.jump_count = 1
			player._set_state(player.FALL_STATE)

		pass

	func input(event):
		if((Input.is_action_pressed(player.Input_Jump)) ||Input.is_joy_button_pressed(player.controller, JOY_XBOX_Y)):
			player._set_state(player.PREJUMP_STATE)
		#if((Input.is_action_pressed("Player1_Down")) || (Input.get_joy_axis(player.controller, JOY_AXIS_1) > 0.5)):
			#player._set_state(player.CROUCH_STATE)

		pass

	func exit():
		pass

# RUNNINGTURN STATE -------------------------------------------------------

class RunningTurn_State:
	var player

	func _init(player):
		self.player = player

		#print("Running Turn")

		player.get_node("AnimationPlayer").play("RunningTurn")

		pass

	func update(delta):

		player.Axis = player.axis_Calculator(player.Axis)

		if(!player.get_node("AnimationPlayer").is_playing()):
			player._set_state(player.RUN_STATE)

		if(player.leaned == true):
			if(player.get_node("RayCast_Middle").is_colliding()):
				player.leaned = false

		player.check_lean()

		player.player_physics(Vector2(400, 300), delta, false,120)

		if(!player.get_node("RayCast_Middle").is_colliding() && !player.get_node("RayCast_Left").is_colliding() && !player.get_node("RayCast_Right").is_colliding()):
			player.jump_count = 1
			player._set_state(player.FALL_STATE)

		pass

	func input(event):
		if((Input.is_action_pressed(player.Input_Jump)) ||Input.is_joy_button_pressed(player.controller, JOY_XBOX_Y)):
			player._set_state(player.PREJUMP_STATE)
		#if((Input.is_action_pressed("Player1_Down")) || (Input.get_joy_axis(player.controller, JOY_AXIS_1) > 0.5)):
			#player._set_state(player.CROUCH_STATE)

		pass

	func exit():
		pass


# WALLSLIDE STATE--------------------------------------------------

class WallSlide_State:
	var player
	var side

	func _init(player):
		self.player = player
		
		#print("Slide")
		
		player.get_node("AnimationPlayer").play("WallSlide")
		player.ran = false
		player.get_node("SamplePlayer2D").play("Land")
		
		#player.raycast_side.set_enabled(true)
		player.raycast_side.set_cast_to(Vector2((player.facing_Right_Num * 5),0))
		player.raycast_side.set_pos(Vector2((player.facing_Right_Num * 9),0))
		
		pass
		
	func update(delta):
		
		player.Axis = player.axis_Calculator(player.Axis)

		if(player.get_node("RayCast_Middle").is_colliding()):
			player._set_state(player.LAND_STATE)

		player.player_physics(Vector2(400, 50), delta, false,120)
		
		if(!player.raycast_side.is_colliding()):
			#print(player.raycast_side.get_pos())
			player._set_state(player.FALL_STATE)
		#else:
			#print("Colliding")
		
		pass

	func input(event):
		if((player.Axis.x < 0.5 && player.facing_Right) || (player.Axis.x > -0.5 && !player.facing_Right)):
			
			if(player.ran):
				player.update_side(!player.facing_Right)
				player.jump_Type = true
				player._set_state(player.JUMP_STATE)
			else:
				player._set_state(player.FALL_STATE)

		pass

	func exit():
		pass

# LAUNCH STATE -------------------------------------------------------

class Launch_State:
	var player
	var joy

	func _init(player):
		self.player = player

		#print("Fall")
		player.get_node("AnimationPlayer").play("Jump2")
		pass

	func update(delta):
	
		player.Axis = player.axis_Calculator(player.Axis)

		if((Input.is_joy_button_pressed(player.controller, JOY_XBOX_Y) || Input.is_action_pressed(player.Input_Jump)) && player.jump_count > 0):
			player._set_state(player.JUMP_STATE)

		if(player.get_node("RayCast_Middle").is_colliding()):
			#Change to slam state
			player._set_state(player.LAND_STATE)
		else:
			player.get_node("Sprite").set_rot(atan2(-player.velocity.x, -player.velocity.y))
			player.player_physics(Vector2(400, 300), delta,true,120)
			
	func input(event):
		pass

	func exit():
		player.get_node("Sprite").set_rot(0)
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

# INTRO STATE -------------------------------------------------------

class Intro_State:
	var player
	var throw = false

	func _init(player):
		self.player = player
		
		player.get_node("Area2D").set_monitorable(false)
		player.get_node("AnimationPlayer").play("Intro")
		#Fix
		player.set_pos(player.get_tree().get_root().get_node("Node").spawnpoints[player.controller])
		pass

	func update(delta):
		if(!player.get_node("AnimationPlayer").is_playing()):
			player._set_state(player.IDLE_STATE)
		pass

	func input(event):
		
		pass

	func exit():
		player.get_node("Area2D").set_monitorable(true)
		pass