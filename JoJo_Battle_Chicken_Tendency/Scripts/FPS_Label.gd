extends Label

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)

func _fixed_process(delta):
	set_text(str(OS.get_frames_per_second()))
