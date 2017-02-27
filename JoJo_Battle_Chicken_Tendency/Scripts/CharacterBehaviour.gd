extends KinematicBody2D

const gravity = 300
var velocity = Vector2()
var max_fall_velocity = 10
var max_air_velocity = 5
var raycast_left 
var raycast_right
var grounded = false
var leaned = false

var Axis = Vector2(0,0)

#This is gonna be used to figure out how fast you are moving the joy stick
var previous_axis 
var ran = false

export var controller = 0

var facing_Right = true
# Left = -1 Right = 1
var facing_Right_Num = 1

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

var walk_Speed = 600

#Update This
var max_walk_speed = 100
#var friction = 120

var jump_count = 2

#Control Name Variables
export var Input_Left = " "
export var Input_Right = " "
export var Input_Up = " "
export var Input_Down = " "
export var Input_Jump = " "
export var Input_Taunt = " "

onready var state = Fall_State.new(self)

func _ready():
	
	raycast_left = get_node("RayCast_Left")
	raycast_right = get_node("RayCast_Right")
	
	raycast_left.add_exception(self)
	raycast_right.add_exception(self)
	
	set_fixed_process(true)
	set_process_input(true)
	pass

func _fixed_process(delta):
	
	get_node("Sprite").set_flip_h(!facing_Right)
	
	if(facing_Right):
		facing_Right_Num = 1
	else:
		facing_Right_Num = -1
		
	state.update(delta)
	
	pass

func _input(event):
	state.input(event)
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
		pass

func _get_state():
	if(state extends Idle_State):
		return IDLE_STATE
	elif(state extends Taunt_State):
		return TAUNT_STATE
	pass
	
func player_physics(var speed, delta, var input, var friction):
	var force = Vector2(0, gravity)
	#speed = Vector2()
	var o
	
	o = input_caculator(o)
	
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
	
	if (is_colliding()):
		
		var n = get_collision_normal()
		
		if(rad2deg(acos(n.dot(Vector2(0, -1)))) < 40):
			floor_velocity = get_collider_velocity()
		if(force.x == 0 and get_travel().length() < 1 and abs(velocity.x) < 1 and get_collider_velocity() == Vector2()):
			revert_motion()
			velocity.y = 0.0
		else:
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			
			move(motion)
	
	if(floor_velocity != Vector2()):
		move(floor_velocity)
	
	pass

func input_caculator(var p):
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
		#else:
			#ran = false
			
	previous_axis = p

	return p

func flip():
	facing_Right = !facing_Right
			

func check_lean():
	if(!facing_Right):
		if((!get_node("RayCast_Middle").is_colliding() && get_node("RayCast_Right").is_colliding()) && !leaned):
			leaned = true
			_set_state(LEAN_STATE)
	else:
		if((!get_node("RayCast_Middle").is_colliding() && get_node("RayCast_Left").is_colliding()) && !leaned):
			leaned = true
			_set_state(LEAN_STATE)

# IDLE STATE -------------------------------------------------------

class Idle_State:
	var player;
	
	func _init(player):
		self.player = player
		
		print("Idle")
		
		player.ran = false
		
		player.get_node("AnimationPlayer").play("Idle")
		pass
		
	func update(delta):
		
		player.Axis = player.input_caculator(player.Axis)
		
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
		
			
		if(Input.is_action_pressed(player.Input_Taunt)):
			player._set_state(player.TAUNT_STATE)
		player.player_physics(Vector2(400, 400),delta,true,120)
		
		player.check_lean()
		
		if(!player.get_node("RayCast_Middle").is_colliding() && !player.get_node("RayCast_Left").is_colliding() && !player.get_node("RayCast_Right").is_colliding()):
			player.jump_count = 1
			player._set_state(player.FALL_STATE)
			
		pass
		
	func input(event):
		if(Input.is_joy_button_pressed(player.controller, JOY_XBOX_Y) || Input.is_action_pressed(player.Input_Jump)):
			player._set_state(player.PREJUMP_STATE)
		pass

	func exit():
		pass


# TAUNT STATE -------------------------------------------------------

class Taunt_State:
	var player
	
	func _init(player):
		self.player = player
		player.get_node("AnimationPlayer").play("Taunt")
		#player.get_node("AnimationPlayer").connect("finished", player, _to_idle())
		# I will uncomment once we have a real sound effect
		#player.get_node("SamplePlayer2D").play("bitch")
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
		
		print("Fall")
		
		player.get_node("AnimationPlayer").play("Fall")
		pass
		
	func update(delta):
		
		player.Axis = player.input_caculator(player.Axis)
		
		if((Input.is_joy_button_pressed(player.controller, JOY_XBOX_Y) || Input.is_action_pressed(player.Input_Jump)) && player.jump_count > 0):
			player._set_state(player.JUMP_STATE)
		
		if(player.get_node("RayCast_Middle").is_colliding()):
			player._set_state(player.LAND_STATE)
		else:
			player.player_physics(Vector2(400, 400), delta,true,120)
		
		#Fast Fall
		if(player.Axis.y > 0.5):
			player.velocity.y += 20
	
	func input(event):
		pass

	func exit():
		pass

# WALK STATE -------------------------------------------------------

class Walk_State:
	var player
	var b
	
	func _init(player):
		self.player = player
		
		print("Walk")
		
		player.get_node("AnimationPlayer").play("Walk")
		pass
		
	func update(delta):
			
		player.Axis = player.input_caculator(player.Axis)
			
		if(player.leaned == true):
			if(player.get_node("RayCast_Middle").is_colliding()):
				player.leaned = false
				
		if((player.Axis.x < 0.5) && (player.Axis.x > -0.5)):
			player._set_state(player.IDLE_STATE);
			
		player.check_lean()
			
		player.player_physics(Vector2(100, 400), delta, true,120)
		
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


# JUMP STATE -------------------------------------------------------

class Jump_State:
	var player
	
	func _init(player):
		self.player = player
		player.jump_count -= 1
		
		print("Jump")
		
		player.get_node("RayCast_Left").set_enabled(false)
		player.velocity.x += ((player.Axis.x) * 5)
		player.velocity.y = -200
		
#This looks so gross I really want to find a way to fix this.
		if(player.facing_Right):
			if(player.Axis.x < -0.1):
				if(player.jump_count == 1):
					player.get_node("Sprite").set_texture(load("res://Characters/Joshep/Sprites/jojo_jump_backwards.png"))
				elif(player.jump_count == 0):
					player.get_node("AnimationPlayer").play("Jump_Backwards_2")
			else:
				if(player.jump_count == 1):
					player.get_node("Sprite").set_texture(load("res://Characters/Joshep/Sprites/jojo_jump.png"))
				elif(player.jump_count == 0):
					player.get_node("AnimationPlayer").play("Jump2")
		else:
			if(player.Axis.x < -0.1):
				if(player.jump_count == 1):
					player.get_node("Sprite").set_texture(load("res://Characters/Joshep/Sprites/jojo_jump.png"))
				elif(player.jump_count == 0):
					player.get_node("AnimationPlayer").play("Jump2")
			else:
				if(player.jump_count == 1):
					player.get_node("Sprite").set_texture(load("res://Characters/Joshep/Sprites/jojo_jump_backwards.png"))
				elif(player.jump_count == 0):
					player.get_node("AnimationPlayer").play("Jump_Backwards_2")
		pass
		
	func update(delta):
		
		player.Axis = player.input_caculator(player.Axis)
		
		if(player.velocity.y >= 0):
			player.get_node("RayCast_Left").set_enabled(true)
			player.get_node("Sprite").set_rot(0)
			player._set_state(player.FALL_STATE);
		player.player_physics(Vector2(400, 400),delta,true,120)
		pass
		
	func input(event):
		if((Input.is_joy_button_pressed(player.controller, JOY_XBOX_Y) || Input.is_action_pressed(player.Input_Jump)) && player.jump_count > 0):
			player._set_state(player.JUMP_STATE)
		pass

	func exit():
		pass

# LAND STATE -------------------------------------------------------

class Land_State:
	var player
	var frames
	
	func _init(player):
		self.player = player
		
		player.jump_count = 2
		
		print("Land")
		
		#TODO: Make Land animation
		player.get_node("AnimationPlayer").play("Land")
		pass
		
	func update(delta):
		#Also add in slide
		if(!player.get_node("AnimationPlayer").is_playing()):
			player._set_state(player.IDLE_STATE)
		player.player_physics(Vector2(400, 400),delta,false,120)
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
		player.get_node("AnimationPlayer").play("Idle")
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
		print("Crouch")
		player.get_node("AnimationPlayer").play("Crouch")
		pass
		
	func update(delta):
		player.Axis = player.input_caculator(player.Axis)
		
		player.player_physics(Vector2(400, 400),delta,false,540)
		
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
		print("PreJump")
		player.get_node("AnimationPlayer").play("PreJump")
		pass
		
	func update(delta):
		if(!player.get_node("AnimationPlayer").is_playing()):
			player._set_state(player.JUMP_STATE)
		player.player_physics(Vector2(400, 400), delta, false,120)
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
		print("Lean")
		
		
		#Does melee have this? Cause I don't think it does.
		player.velocity.x = 0
		player.velocity.y = 0
		
		player.get_node("AnimationPlayer").play("Lean")
		pass
		
	func update(delta):
		
		player.Axis = player.input_caculator(player.Axis)
		
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
		
		#if(player.facing):
		#	player.velocity.x += -400
		#else:
		#	player.velocity.x += 100
		print("Run")
		
		player.get_node("AnimationPlayer").play("Run")
		pass
		
	func update(delta):
			
		player.Axis = player.input_caculator(player.Axis)
			
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
			
		player.player_physics(Vector2(600, 400), delta, true,120)
		
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


#This might be unnescisary
# SLIDE STATE -------------------------------------------------------

class Slide_State:
	var player
	var b
	
	func _init(player):
		self.player = player
		
		print("Slide")
		
		player.get_node("AnimationPlayer").play("Slide")
		
		pass
		
	func update(delta):
			
		player.Axis = player.input_caculator(player.Axis)
			
		if(player.leaned == true):
			if(player.get_node("RayCast_Middle").is_colliding()):
				player.leaned = false
				
		if(player.velocity.x < 0.1 && player.velocity.x > -0.1):
			player._set_state(player.IDLE_STATE);
			
		if(player.facing_Right && player.Axis.x < -0.7):
			player._set_state(player.RUN_STATE);
			
		elif(!player.facing_Right && player.Axis.x > 0.7):
			player._set_state(player.RUN_STATE);
			
		player.check_lean()
			
		player.player_physics(Vector2(400, 400), delta, false,120)
		
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
		
		print("Turn")
		
		if(player.ran):
			player.get_node("AnimationPlayer").set_speed(1.8)
			player.get_node("AnimationPlayer").play("Turn")
		else:
			player.get_node("AnimationPlayer").set_speed(1)
			player.get_node("AnimationPlayer").play("Turn")
		
		
		pass
		
	func update(delta):
			
		player.Axis = player.input_caculator(player.Axis)
			
		if(!player.get_node("AnimationPlayer").is_playing()):
			if(player.ran):
				player._set_state(player.DASH_STATE)
			else:
				player._set_state(player.IDLE_STATE)
			
		if(player.leaned == true):
			if(player.get_node("RayCast_Middle").is_colliding()):
				player.leaned = false
			
		player.check_lean()
			
		player.player_physics(Vector2(400, 400), delta, false,120)
		
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
		
		print("Dash")
		
		player.get_node("AnimationPlayer").play("Dash")
		
		if(player.facing_Right):
			player.velocity.x = 200
		else:
			player.velocity.x = -200
		
		pass
		
	func update(delta):
			
		player.Axis = player.input_caculator(player.Axis)
			
		if(!player.get_node("AnimationPlayer").is_playing()):
				player._set_state(player.RUN_STATE)
		
		if(player.Axis.x < -0.3 && player.facing_Right && player.ran):
			player.facing_Right = !player.facing_Right
			player._set_state(player.DASH_STATE)
			pass
		elif(player.Axis.x > 0.3 && !player.facing_Right && player.ran):
			player.facing_Right = !player.facing_Right
			player._set_state(player.DASH_STATE)
			pass
		
		if(player.leaned == true):
			if(player.get_node("RayCast_Middle").is_colliding()):
				player.leaned = false
			

			
		player.check_lean()
			
		player.player_physics(Vector2(400, 400), delta, false,120)
		
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
		
		print("Running Turn")
		
		player.get_node("AnimationPlayer").play("RunningTurn")
		
		pass
		
	func update(delta):
			
		player.Axis = player.input_caculator(player.Axis)
			
		if(!player.get_node("AnimationPlayer").is_playing()):
			player._set_state(player.RUN_STATE)
			
		if(player.leaned == true):
			if(player.get_node("RayCast_Middle").is_colliding()):
				player.leaned = false
			
		player.check_lean()
			
		player.player_physics(Vector2(400, 400), delta, false,120)
		
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