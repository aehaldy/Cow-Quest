extends Area2D

var interacting = false
#get parent's name
#NOTE: For parsing, must have unique parent!
#AND, parent of area must be sibling to Player!!
onready var Parent = get_parent()
onready var Grid = get_node("../../../Grid")
var pos #Area/parent's grid pos
var player_pos #player's grid pos
var target_pos #players supposed-to-be pos
var Player 


func _ready():
	#Declare some global arrays --instead of using Groups
	if not Globals.has("inactive_group"):
		Globals.set("inactive_group",[])
	
	
func _process(delta):
	#	Wait for Player to fully move onto current grid tile.
	if Player.is_moving == false:
		_complete_event()
		
		
func _input(event):
	if ( event.is_action_pressed( "ui_accept" ) 
		&& !event.is_echo() 
		&& interacting == true 
		&& !Globals.inactive_group.has( Parent.get_name() ) ):
		#get this node's x,y
		pos = get_global_pos()
		#call Player function to check Input
		#send this Object's x,y
		get_node("../../Player")._interact( Parent, pos )
	else:
		pass


func _on_Interaction_body_enter( body ):
	#Check if it's the Player
	if Globals.inactive_group.has( Parent.get_name() ):
	#if Parent.is_in_group("Inactive"):
		pass
	elif body.get_name() == "Player":
		interacting = true
		Player = body
		#Check if this area's parent is input or contact activated
		if Parent.is_in_group("Auto_Interact"):
			Player.facing_interactor = true
			set_process( true )
		else:
			set_process_input( true )
	else:
		pass


func _complete_event():
	set_process( false )
	var passability = false
	if Parent.is_in_group("Passable"):
		passability = true
	Player._get_dialog( Parent, passability )
	

func _on_Interaction_body_exit( body ):
	#Turn off processing in this node
	if body.get_name() == "Player":
		interacting = false
		set_process_input( false )
	#resume NPC object movement if not talking to Player
	if ( Parent.has_method("_tween_pos")
		&& not Parent.talking 
		&& not Parent.can_move):
		Parent._resume_move()
	else:
		pass