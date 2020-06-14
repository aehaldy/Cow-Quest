
extends KinematicBody2D


#CHANGE ThiS ACCORDING to GAME PARAMETERS!
var tile_size = Vector2(64,64) 
#For coordinating with parent Grid 
onready var Grid = get_parent()

signal DONE

var type
var is_moving = false
var dir = Vector2()
var next_pos = Vector2()
var target_pos = Vector2()
var pos #Player pos
var start_pos

#Movement is conducted via Tween
onready var Tweener = get_node("Tween")
var tweenkey = ""
var speed = 1 #default speed is 1 second, to move 1 tile 
#(^ speed is in seconds; to move faster, decrease ^)

#For animating player sprite
onready var Aniplayer = get_node("AnimationPlayer")
var anim = ""
var new_anim = "" #for updating animation

#controlling movement
var move_loop = true
var can_move = true
var talking = false
onready var self_name = get_name()

onready var Spritenode = get_node("Sprite")

#=============================================================================

func _ready():
	Tweener.connect("tween_complete", self, "_tween_done")
	#wait until parent ready!
	type = Grid.INTERACTOR
	#Look up the movement pattern for the NPC, and play it
	yield(get_tree(), 'idle_frame')
	_get_pattern(self)


func _tween_pos():
	#Check if animation needs updating:
	if (new_anim!=anim):
		anim=new_anim
		Aniplayer.play(anim)
	#Check movement for collisions or other problems:
	if get_pos() != target_pos:
		if test_move(dir*(tile_size/2)) == false:
			if Grid.is_cell_vacant( get_pos(), dir ) == null:
				#No collision, and target is on map
				next_pos = Grid.update_child_pos(self) 
				Tweener.interpolate_property( self, 'transform/pos', get_pos(), next_pos, 
					speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT )
				Tweener.start()

			else:
				var collider = Grid.is_cell_vacant( get_pos(), dir )
				if collider == 0 or 2:
					#store boolean that npc is blocked
					can_move = false
					#Stop animation
					Aniplayer.stop()
					#when body exits, area calls _resume_move()
				else:
					#It's an obstacle, won't move, so stop:
					dir = Vector2()
					self.emit_signal('DONE')
		else:
			#lookup tile on grid to see what's there
			var collider = Grid.is_cell_vacant( get_pos(), dir )
			#react accordingly
			if collider == 0 or 2:
				#store boolean that npc is blocked
				can_move = false
				#Stop animation
				Aniplayer.stop()
				#when body exits, area sends back to resume the tween/animation
				
			else:
				#It's an obstacle, won't move, so stop:
				dir = Vector2()
				self.emit_signal('DONE')
	else:
		#Have reached target, so stop:
		dir = Vector2()
		self.emit_signal('DONE')
		
		
func _tween_sprite( sprite, to_pos, how_fast ):
	#Check if animation needs updating:
	if (new_anim!=anim):
		anim=new_anim
		Aniplayer.play(anim)
	#	No need to check collision or use Grid,
	#	because we are merely moving a sprite
	#	for animation effets, not changing pos
	Tweener.interpolate_property( sprite, 'transform/pos', sprite.get_pos(), to_pos, 
		how_fast, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT )
	Tweener.start()


func _tween_done(obj, key):
	if ( can_move && obj == self 
		&& key == "transform/pos" ):
		_tween_pos()
	elif ( obj == Spritenode
		&& key == "transform/pos" ):
		self.emit_signal('DONE')
	else:
		pass
	

func _resume_move():
	if (new_anim!=anim):
		anim=new_anim
	Aniplayer.play(anim)
	can_move = true
	talking = false
	if Tweener.get_runtime() > 0.1:
		Tweener.resume(self, tweenkey)
	elif tweenkey == 'transform/pos':
		_tween_pos()
	#Update grid to correct any pos errors...?


#-------------------------------------
#	Basic Move Patterns
#-------------------------------------

func _talk_to_player():
	can_move = false
	talking = true
	#stop the current tween, if active
	Tweener.stop(self,tweenkey)
	#var old_anim = Aniplayer.get_animation()
	#get Player.facing
	var pface = get_node("../Player").facing
		#use player.facing to play animation in right direction
	if pface == "up":
		anim = "idle"
	elif pface == "right":
		anim = "face_l"
	elif pface == "left":
		anim = "face_r"
	elif pface == "down":
		anim = "face_u"
	Aniplayer.play(anim)
	

func _turn(dir):
	if dir == "d":
		anim = "idle"
	elif dir == "l":
		anim = "face_l"
	elif dir == "r":
		anim = "face_r"
	else:
		anim = "face_u"
	Aniplayer.play(anim)


func _idle( fidget=false ): 
	if fidget == true:
		Aniplayer.play("fidget")
	else:
		Aniplayer.play("idle")


func _step_l(steps=1):
	#store tweenkey for outside reference
	tweenkey = 'transform/pos'
	dir.x = -1
	pos = get_pos()
	target_pos = Vector2(pos.x-(steps*tile_size.x), pos.y) 
	#Sprite/AnimationPlayer must have this animation:
	new_anim = "walk_l"
	if can_move:
		_tween_pos()
	
	
func _step_r(steps=1):
	#store tweenkey for outside reference
	tweenkey = 'transform/pos'
	dir.x = 1
	pos = get_pos()
	target_pos = Vector2(pos.x+(steps*tile_size.x), pos.y) 
	#Sprite/AnimationPlayer must have this animation:
	new_anim = "walk_r"
	if can_move:
		_tween_pos()
	

func _jump():
	#tweenkey = 'transform/pos'
	#save sprite's current pos
	var old_pos = Spritenode.get_pos()
	#set animation
	new_anim = "jump1"
	#calculate jump apex
	var apex = Vector2(old_pos.x, old_pos.y-(tile_size.y/2))
	#play SE
	Sound._play_fx("jump")
	#first tween
	_tween_sprite(Spritenode, apex, .15)
	yield(self, 'DONE')
	#set animation
	new_anim = "jump2"
	#use sprites old pos
	_tween_sprite(Spritenode, old_pos, .15)
	
	
	
func _jump_r():
	#tweenkey = 'transform/pos'
	#save sprite's current pos
	var old_pos = Spritenode.get_pos()
	#set animation
	new_anim = "jump1_r"
	#calculate jump apex
	var apex = Vector2(old_pos.x, old_pos.y-(tile_size.y/2))
	#play SE
	Sound._play_fx("jump")
	#first tween
	_tween_sprite(Spritenode, apex, .15)
	yield(self, 'DONE')
	#set animation
	new_anim = "jump2_r"
	#use sprites old pos
	_tween_sprite(Spritenode, old_pos, .15)
	
	
func _jump_l():
	#tweenkey = 'transform/pos'
	#save sprite's current pos
	var old_pos = Spritenode.get_pos()
	#set animation
	new_anim = "jump1_l"
	#calculate jump apex
	var apex = Vector2(old_pos.x, old_pos.y-(tile_size.y/2))
	#play SE
	Sound._play_fx("jump")
	#first tween
	_tween_sprite(Spritenode, apex, .15)
	yield(self, 'DONE')
	#set animation
	new_anim = "jump2_l"
	#use sprites old pos
	_tween_sprite(Spritenode, old_pos, .15)
	
	
func _random():
	#TBD
	pass

#+++++++++++++++++++++++++++++++++++++
#	Specialized Move Patterns
#+++++++++++++++++++++++++++++++++++++
	
func _left_right_4_tiles():
	_step_l(2)
	yield(self, 'DONE')
	_step_r(3)
	yield(self, 'DONE')
	_step_l(1)
	yield(self, 'DONE')
	if move_loop == true:
		_left_right_4_tiles()
	
	
func _fairy_magic_u():
	Aniplayer.play("magic_u")
	
	
func _fairy_magic_particles():
	var Parts = get_node("Particles2D")
	var Sparkles = get_node("../Sparkle")
	if Sparkles.is_emitting():
		Sparkles.set_emitting(false)
	if Aniplayer.get_current_animation() == "magic_u":
		#set partile emission point & direction
		Parts.set_emissor_offset(Vector2(0,-30))
		Parts.set_param(0,180)
		Parts.set_emitting(true)
		Sparkles.set_emit_timeout(4)
		Sparkles.set_pos(Vector2(3072,1088))
		Sparkles.set_emitting(true)
	elif Aniplayer.get_current_animation() == "magic_l":
		#set particle emission point & direction
		Parts.set_emissor_offset(Vector2(-15,8))
		Parts.set_param(0,270)
		Sparkles.set_emit_timeout(0)
		#Sparkles.set_pos(Vector2(2990,1216)) #set pos in parser
		#play sound FX
		Sound._play_fx("sparkles")
		Parts.set_emitting(true)
		Sparkles.set_emitting(true)
		emit_signal("DONE")
	else:
		pass
		
	
#===============================================================
#	HERE Be Ye Movement PATTERNS ..*.*..*.*..*.
#===============================================================
	
func _get_pattern(npc_node):
	var interactor = npc_node.get_name()
	
	if interactor == 'Cave_Witch':
		if Globals.get("talked_to_witch_bool") == true:
			#May use conditional statements here to change movement
			move_loop == true
			_left_right_4_tiles()
		else:
			_idle()
	elif interactor == 'Forest_Fairy':
		_fairy_magic_u()
	elif interactor == 'Forest_Jack':
		if Globals.get("got_daisy") == true:
			self.queue_free()
		else:
			_idle(true)
	else:
		#If no movement is assigned, the npc will move randomly
		_random()