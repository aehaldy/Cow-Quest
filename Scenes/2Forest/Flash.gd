extends CanvasLayer

onready var Frame = get_node("ColorFrame")
onready var Aniplayer = get_node("AnimationPlayer")

func _yellow_flash():
	Frame.set_frame_color('f2ff80')
	Aniplayer.play('flash')
	
func _blue_flash():
	Frame.set_frame_color('89deff')
	Aniplayer.play('flash')

func _shadow_pulse():
	Frame.set_frame_color('3c344f')
	Aniplayer.play('pulse')