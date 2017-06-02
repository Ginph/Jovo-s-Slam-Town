extends Camera

func _ready():
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	self.set_rotation(Vector3(0,self.get_rotation().y + 0.001,0))