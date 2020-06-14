extends Node2D

signal BALLOON_POP
var Aniplayer
var Balloon
var old_pos

func _ready():
	Aniplayer = get_node("AnimationPlayer")
	Balloon = get_node("Sprite")
	Aniplayer.connect("finished", self, "_done")
	

func _balloon( pos, anim ):
	#===============================================
	#		Animations list:
	#	'exclamation', 'teardrop'
	#
	#===============================================
	old_pos = get_pos()
	#Locate the balloon at pos (balloon animates in tile above)
	set_pos(pos)
	#play animation
	Aniplayer.play(anim)
	
	
func _done():
	#remove balloon from screen
	set_pos(old_pos)
	emit_signal("BALLOON_POP")

