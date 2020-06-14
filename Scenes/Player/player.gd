extends KinematicBody2D

signal DONE
signal AnimTimer

#For coordinating with parent Grid 
onready var Grid = get_parent()
var type
onready var tile_size = Grid.tile_size #CHANGE ThiS ACCORDING to GAME PARAMETERS!
var is_moving = false
var dir = Vector2()
var target_pos = Vector2()
var target_dir = Vector2()
var pos #Player pos
var old_pos #for correcting grid after cutscene animations

#for controlling how fast to move
var speed = 0
const MOVE_SPEED = 220
const DASH_SPEED = 340
var velocity

#For animating player sprite
onready var Aniplayer = get_node("AnimationPlayer")
var anim = ""
onready var Tweener = get_node("Tween")

#For checking facing direction/interaction
var facing = "down"
var facing_interactor = false
var can_move = true
var auto_move = false

#For moving the cow (and placing in Cave)
onready var cow_pos = Vector2(543,1055)
#==============================================================================


func _ready():
	if not Aniplayer.is_connected("finished", self, "_animation_done"):
		Aniplayer.connect("finished", self, "_animation_done")
	# Some Global variables are needed to play as Player
	# We can create them here: (or move this to first scene...perhaps)
	
	#Children of Grid who occupy space must get a type
	#The Player is PLAYER, others are OBSTACLE (static) and INTERACTOR (dynamic)
	type = Grid.PLAYER
	set_fixed_process(true)
	
	
func _fixed_process(delta):
	#May wish to break out input, movement and animation into a separate function 
	dir = Vector2()
	var is_dashing = Input.is_action_pressed("ui_dash")
	var new_anim = anim
		
	if Input.is_action_pressed("ui_move") and not auto_move:
		if Input.is_action_pressed("ui_up"):
			dir.y = -1
			new_anim = "walk_up"
			facing = "up"
		elif Input.is_action_pressed("ui_down"):
			dir.y = 1
			new_anim = "walk_down"
			facing = "down"
		if Input.is_action_pressed("ui_right"):
			dir.x = 1
			new_anim = "walk_right"
			facing = "right"
		elif Input.is_action_pressed("ui_left"):
			dir.x = -1
			new_anim = "walk_left"
			facing = "left"

	if can_move and not is_moving and dir != Vector2():
		target_dir = dir.normalized() 
		if (new_anim!=anim):
			anim=new_anim
			Aniplayer.play(anim)
		#check for collisions:
		if test_move(target_dir*tile_size) == false:
			var gri = Grid.is_cell_vacant(get_pos(), target_dir)
			if gri != (1 or 2):
				target_pos = Grid.update_child_pos(self)
				is_moving = true
	elif can_move and is_moving and is_dashing:
		speed = DASH_SPEED
		Aniplayer.set_speed(2)
	elif (can_move or auto_move) and is_moving:
		speed = MOVE_SPEED
		Aniplayer.set_speed(1)
	else:
		speed = 0
		anim = "idle"
		Aniplayer.stop()
	
	velocity = speed * target_dir * delta
	pos = get_pos()
	var distance_to_target = Vector2(abs(target_pos.x-pos.x), abs(target_pos.y-pos.y))
	
	if abs(velocity.x) > distance_to_target.x:
		velocity.x = distance_to_target.x * target_dir.x
		is_moving = false
	if abs(velocity.y) > distance_to_target.y:
		velocity.y = distance_to_target.y * target_dir.y
		is_moving = false
		
	move(velocity)
	cow_pos = pos
	
	
func _interact( Interactor, interactor_pos ):
	# If we want the player to stand ON something an interact
	# a different script will be required.
	# For now, this only lets the player interact with
	# something (s)he's standing next to...
	
	#	STEP ONE 
	#	Check if Player is facing the interactor node
	
		#First, get Player positions 
	pos = get_pos() 
		#Check interactor_pos in relation to Player pos
	if facing == "up" && round(pos.y)-tile_size.y == interactor_pos.y:
		facing_interactor = true
	elif facing == "down" && round(pos.y)+tile_size.y == interactor_pos.y:
		facing_interactor = true
	elif facing == "right" && round(pos.x)+tile_size.x == interactor_pos.x:
		facing_interactor = true
	elif facing == "left" && round(pos.x)-tile_size.x == interactor_pos.x:
		facing_interactor = true
	else:
		facing_interactor = false
	
	if facing_interactor == true:
		_get_dialog(Interactor)
	else:
		return
	
	
func _get_dialog(Interactor, passibility=false):
	#	get Dialogbox node for function calling...
	#	NOTE, Dialogbox (CanvasLayer) must be sibling of Grid!
	var db = get_node("../../Dialogbox/PanelContainer")
	# STEP TWO
	if passibility == false:
		#stop animation
		Aniplayer.stop()
		#stop movement input
		can_move = false
		set_fixed_process(false)
	DialogParser._interaction( Interactor, db, self)
	
	
func _release():
	set_fixed_process(true)
	auto_move = false
	can_move = true
	
	
func _correct_pos():
	#Just to make sure that, after animation, player pos is on grid
	Grid.correct_grid(self, old_pos)
	print("NOW Player @ pos ", get_pos())
	_release()
	
	
#=============================================================
#
#	*   Here Be Ye Other Player Animated Movements!   *
#
#=============================================================
	
func _step_up( steps=1 ): #Ask Grid to move player (x steps/tiles) up
	#set bools
	can_move = false
	auto_move = true
	set_fixed_process(true)
	#get variables and play animation
	dir.y = -steps #does it matter if this is greater than 1??
	facing = "up"
	anim = "walk_up"
	#make sure animation player 'Aniplayer' is active and play rate is normal
	#set_fixed_process(false)
	Aniplayer.set_active(true)
	Aniplayer.play(anim)
	#if steps > 0:
	target_dir = dir.normalized()
	#check for wandering npcs (not sure this covers vector? Test move instead?:
	if Grid.is_cell_vacant(get_pos(), target_dir) != 2:
		target_pos = Grid.update_child_pos(self)
		is_moving = true
		_release()
	else:
		_step_up( steps )
		
		
func _step_down( steps=1 ): #Ask Grid to move player (x steps/tiles) up
	#set bools
	can_move = false
	auto_move = true
	set_fixed_process(true)
	#get variables and play animation
	dir.y = steps
	facing = "down"
	anim = "walk_down"
	#make sure animation player 'Aniplayer' is active and play rate is normal
	#set_fixed_process(false)
	Aniplayer.set_active(true)
	Aniplayer.play(anim)
	#if auto_move and not is_moving and dir != Vector2():
	target_dir = dir.normalized()
	#check for wandering npcs (not sure this covers vector? Test move instead?:
	if Grid.is_cell_vacant(get_pos(), target_dir) != 2:
		target_pos = Grid.update_child_pos(self)
		is_moving = true
		_release()
	else:
		_step_down( steps )
	
	
func _step_left( steps=1, cutscene_over=true ):
	#set bools
	can_move = false
	auto_move = true
	set_fixed_process(true)
	#get variables and play animation
	dir.x = -steps
	facing = "left"
	anim = "walk_left"
	#make sure animation player 'Aniplayer' is active and play rate is normal
	Aniplayer.set_active(true)
	Aniplayer.play(anim)
	#if steps > 0? for multiple steps, need counter?
	target_dir = dir.normalized()
	#check for wandering npcs (not sure this covers vector?):
	if Grid.is_cell_vacant(get_pos(), target_dir) != 2:
		target_pos = Grid.update_child_pos(self)
		is_moving = true
		if cutscene_over == true:
			#if the cutscene is over, release player
			_release()
	else:
		_step_left( steps, cutscene_over )
	
	
func _step_right( steps=1, cutscene_over=true ):
	#set bools
	can_move = false
	auto_move = true
	set_fixed_process(true)
	#get variables and play animation
	dir.x = steps
	facing = "right"
	anim = "walk_right"
	#make sure animation player 'Aniplayer' is active and play rate is normal
	Aniplayer.set_active(true)
	Aniplayer.play(anim)
	#if steps > 0? for multiple steps, need counter?
	target_dir = dir.normalized()
	#check for wandering npcs (not sure this covers vector?):
	if Grid.is_cell_vacant(get_pos(), target_dir) != 2:
		target_pos = Grid.update_child_pos(self)
		is_moving = true
		if cutscene_over == true:
			#if the cutscene is over, release player
			_release()
	else:
		_step_left( steps, cutscene_over )
	
	
func _step_back( steps=1, cutscene_over=true ): #Ask Grid to move player (x steps/tiles) up
	#dir = Vector2(0,0)
	#set bools
	can_move = false
	auto_move = true
	set_fixed_process(true)
	#get variables and play animation
	if facing == "up":
		dir.y = steps
		anim = "walk_up"
	elif facing == "right":
		dir.x = -steps
		anim = "walk_right"
	elif facing == "left":
		dir.x = steps
		anim = "walk_left"
	else:
		dir.y = -steps
		anim = "walk_down"
	#make sure animation player 'Aniplayer' is active and play rate is normal
	Aniplayer.set_active(true)
	Aniplayer.play(anim)
	#if auto_move and not is_moving and dir != Vector2():
	target_dir = dir.normalized()
	#check for wandering npcs (not sure this covers vector? Test move instead?:
	if Grid.is_cell_vacant(get_pos(), target_dir) != 2:
		target_pos = Grid.update_child_pos(self)
		is_moving = true
		if cutscene_over == true:
			#if the cutscene is over, release player
			_release() 
	else:
		_step_back( steps, cutscene_over )
	
	
func _climb_d(): #ideally in future, make so can climb multiple tiles
	speed = MOVE_SPEED
	can_move = false
	set_fixed_process(false)
	if not Tweener.is_connected("tween_complete", self, "_tween_done"):
		Tweener.connect("tween_complete", self, "_tween_done")
	# vec is direction, tile value to move: -1,2 = left 1, down 2 tiles
	var vec = Vector2(0,2) #CHANGE this as desired for climb distance, direction
	#Calculate new position
	var new_pos = vec * tile_size
	#play animation
	Aniplayer.play("climb_d")
	#call Tween
	_tween_pos( new_pos, 1.5)
	
	
func _climb_u(): #ideally in future, make so can climb multiple tiles
	speed = MOVE_SPEED
	can_move = false
	set_fixed_process(false)
	if not Tweener.is_connected("tween_complete", self, "_tween_done"):
		Tweener.connect("tween_complete", self, "_tween_done")
	# vec is direction, tile value to move: -1,2 = left 1, down 2 tiles
	var vec = Vector2(0,-2) #CHANGE this as desired for climb distance, direction
	#Calculate new position
	var new_pos = vec * tile_size
	#play animation
	Aniplayer.play("climb_u")
	#call Tween
	_tween_pos( new_pos, 1.5)
	
	
func _jump_back( tiles ):
	var vec
	if facing == "up":
		vec = Vector2(0,tiles)
	elif facing == "right":
		vec = Vector2((-1*tiles),0)
	elif facing == "left":
		vec = Vector2(tiles,0)
	else:
		vec = Vector2(0,(-1*tiles))
	can_move = false
	set_fixed_process(false)
	if not Tweener.is_connected("tween_complete", self, "_tween_done"):
		Tweener.connect("tween_complete", self, "_tween_done")
	var first_pos = ((vec*tile_size)/2) - Vector2(0,(tile_size.y/2)) #create the midpoint arc
	var final_pos = first_pos + Vector2(0,(tile_size.y)) #add back arc difference
	Aniplayer.play(anim) #presumably
	Sound._play_fx("jump")
	_tween_pos( first_pos, .2 )
	yield ( self, "DONE")
	_tween_pos( final_pos, .2 )



func _tween_pos( new_pos, time ):
	var old_pos = get_pos()
	#time is how long the tween must last
	Tweener.interpolate_property(self, "transform/pos", old_pos, old_pos+new_pos, time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	Tweener.start()
	#Update the grid ro reflect new player pos
	Grid.correct_grid(self, old_pos)


func _tween_done( obj, key ):
	emit_signal("DONE")
	
	
func _animation_done():
	emit_signal("AnimTimer")


func _turn_360( times=1 ):
	can_move = false
	set_fixed_process(false)
	if times == 0:
		emit_signal("DONE")
	else:
		Aniplayer.play('360')
		yield( self, 'AnimTimer')
		times = times - 1
		_turn_360(times)
	
