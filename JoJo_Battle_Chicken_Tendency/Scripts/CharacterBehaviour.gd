extends KinematicBody2D

const gravity = 8
var velocity = Vector2()
var max_fall_velocity = 10
var max_air_velocity = 5
var raycast_left 
var raycast_right
var grounded = false

export var controller = 0

#0 = left 1 = right 
var facing = true

const IDLE_STATE = 0
const TAUNT_STATE = 1
const FALL_STATE = 2
const WALK_STATE = 3
const LAND_STATE = 4

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
	if(Input.is_key_pressed(KEY_R)):
		self.set_pos(Vector2(400,50))
		_set_state(FALL_STATE)
	get_node("Sprite").set_flip_h(facing)
	state.update(delta)
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
	pass

func _get_state():
	if(state extends Idle_State):
		return IDLE_STATE
	elif(state extends Taunt_State):
		return TAUNT_STATE
	pass
	
func player_physics(var speed):
	speed = Vector2()
	if(((Input.get_joy_axis(controller, JOY_AXIS_0)) > 0.5 ) || (Input.get_joy_axis(controller, JOY_AXIS_0)) < -0.5):
		velocity.x += (Input.get_joy_axis(controller, JOY_AXIS_0))
	else:
		if(velocity.x > 1 || velocity.x < -1):
			velocity.x = velocity.x / 1.1
		else:
			velocity.x = 0
	move(Vector2(velocity.x,(velocity.y + gravity)))
	pass

# IDLE STATE -------------------------------------------------------

class Idle_State:
	var player;
	
	func _init(player):
		self.player = player
		
		print("Idle")
		
		player.get_node("AnimationPlayer").play("Idle")
		pass
		
	func update(delta):
		if(Input.get_joy_axis(player.controller, JOY_AXIS_0) > 0.5):
			player.facing = false
			player._set_state(player.WALK_STATE)
		elif((Input.get_joy_axis(player.controller, JOY_AXIS_0) < -0.5)):
			player.facing = true
			player._set_state(player.WALK_STATE)
			
		if(Input.is_action_pressed("Player1_Taunt")):
			player._set_state(player.TAUNT_STATE)
		player.player_physics(1)
		pass
		
	func input(event):
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
		player.get_node("SamplePlayer2D").play("bitch")
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
		player.get_node("AnimationPlayer").play("Fall")
		pass
		
	func update(delta):
		#if(((Input.get_joy_axis(player.controller, JOY_AXIS_0)) > 0.5 ) || (Input.get_joy_axis(player.controller, JOY_AXIS_0)) < -0.5):
			#joy = ((Input.get_joy_axis(player.controller, JOY_AXIS_0)) * 2 )
			#player.get_node("Sprite").set_flip_h(false)
		#else:
		#	joy = 0
		#player.move(Vector2(joy, gravity))
		
		if(player.get_node("RayCast_Left").is_colliding()):
			player._set_state(player.LAND_STATE)
		else:
			player.player_physics(1)
		
		
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
			#b = Input.get_joy_axis(player.controller, JOY_AXIS_0)
			
			#player.move(Vector2(b,0))
		
		if(!((Input.get_joy_axis(player.controller, JOY_AXIS_0) > 0.5) || (Input.get_joy_axis(player.controller, JOY_AXIS_0) < -0.5))):
			player._set_state(player.IDLE_STATE);
		player.player_physics(2)
		pass
		
	func input(event):
		pass

	func exit():
		pass


# JUMP STATE -------------------------------------------------------

class Jump_State:
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

# LAND STATE -------------------------------------------------------

class Land_State:
	var player
	var frames
	
	func _init(player):
		self.player = player
		
		print("Land")
		
		#TODO: Make Land animation
		player.get_node("AnimationPlayer").play("Land")
		pass
		
	func update(delta):
		#Also add in slide
		if(!player.get_node("AnimationPlayer").is_playing()):
			player._set_state(player.IDLE_STATE)
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