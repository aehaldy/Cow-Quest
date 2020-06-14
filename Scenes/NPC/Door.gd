extends StaticBody2D

#===================================================
#
#		Basic DOOR Functions
#
#===================================================

#	 NOTE: Door must be sibling of Player!!

onready var Aniplayer = get_node("AnimationPlayer")
onready var Player = get_node("../Player")
var entering #in case wish to implement OTHER door animations in the future...
var next_map #for controlling where the doors leads
var player_pos #to set player pos, which may change

#===================================================

func _ready():
	Aniplayer.connect("finished", self, "_door_done")
	
	
func _enter_door( destination, music=null ):
	Player.can_move = false
	Player.auto_move = true
	entering = true
	next_map = destination 
	Sound._play_fx("door_open")
	Aniplayer.play("open")


func _door_done():
	if entering == true:
		#get_node("CollisionShape2D").free() #Need this?
		Sound._play_fx("map_transition")
		#Sound.fadeout()
		Player._step_up()
		Transition.fade_to(next_map)
		Player._release()
	else:
		pass
