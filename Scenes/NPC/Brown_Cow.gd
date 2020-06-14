extends Node2D

#----------------------------------------------------------------------
# A script, seperate from other NPCs for now, to control the cow sprite
# It's main job is, after collecting the cow, to have the sprite 
# follow the player, with the appropriate directional animation.
#----------------------------------------------------------------------

onready var Player = get_node("../Player")
onready var Aniplayer = get_node("AnimationPlayer")
onready var anim = Aniplayer.get_current_animation()
var new_anim = "graze"
#Movement is conducted via Tween
onready var Tweener = get_node("Tween")
#moving variables:
var player_pos
var new_pos 
var x_diff 
var y_diff
var speed = .7


func _ready():
	Tweener.connect("tween_complete", self, "_tween_done")
	# If not got daisy, play graze animation
	if not Globals.get("got_daisy"):
		Aniplayer.play("graze")
	# else allow fixed processing to follow player
	else:
		self.show()
		set_fixed_process(true)
		

func _fixed_process(delta):
	#Have player input move the cow
	#Adjust cow's position relative to player:
	new_pos = Player.cow_pos

	#Then move the cow accordingly when player moves
	if Input.is_action_pressed("ui_move") and Player.is_moving == true:
		#Choose cow animation based on relative movement direction
		var pos = self.get_global_pos()
		#Moive the cow sprite adjusted to player's speed
		if Player.speed > 220:
			speed = .33
			
		#if new_pos.x > pos.x:
		if Player.facing == "right":
			new_anim = "walk_r"
		#elif new_pos.x < pos.x:
		elif Player.facing == "left":
			new_anim = "walk_l"
		#elif new_pos.y > pos.y:
		elif Player.facing == "down":
			new_anim = "walk_d"
		else:
			new_anim = "walk_u"
		if (new_anim!=anim || !Aniplayer.is_playing()):
			anim = new_anim
			Aniplayer.play(anim)
			
		Tweener.interpolate_property( self, 'transform/pos', pos, new_pos, 
					speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT )
		Tweener.start()
		
	else:
		pass
		
		
func _tween_done(obj, key):
	#Idle the animation if not moving
	if Player.is_moving == false:
		Aniplayer.stop()
	