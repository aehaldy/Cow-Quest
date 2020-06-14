extends Area2D


var interacting = false

onready var Crickbed = get_node("../Crickbed")
onready var Crickbank = get_node("../Crickbank")
onready var Bridge = get_node("../Bridge")
onready var Player = get_node("../Player")
#onready var Butterfly #add collision exception

func _ready():
	pass
	
	
func _on_Vine_body_enter( body ):
	if body.get_name() == "Player":
		interacting = true
		set_process( true )
	
	
func _on_Vine_body_exit( body ):
	if body.get_name() == "Player":
		interacting = false
		set_process( false )
	
	
func _process(delta):
	#	Wait for Player to fully move onto current grid tile.
	if interacting == true && Player.is_moving == false:
		if Bridge.get_z()==0 && Player.facing == "down":
			set_process( false )
			if not Globals.get("first_climb"):
				_first_climb()
				Globals.set("first_climb", true)
			else:
				_enter_crick()
		elif Bridge.get_z()==1 && Player.facing == "up":
			set_process( false )
			_leave_crick()
		else: 
			pass 
	
	
func _first_climb():
	Player.Aniplayer.play("idle")
	Player.can_move = false
	Player.set_fixed_process(false)
	var Dialogbox = get_node("../../Dialogbox/PanelContainer")
	Dialogbox._set_dialog(0, 1, "I could climb down this vine "\
		+ "into the crick bed, \nif I wanted to, for some reason...", 
		"res://Scenes/Player/Player_Neutral.tex",false)
	yield( Dialogbox, "next" )
	Dialogbox._set_dialog( 1, 2, null, null, false, 
		"Climb down!;Seems like too much effort." )
	yield( Dialogbox, "next" )
	var choice = Dialogbox.selection
	if choice == 0:
		_enter_crick()
	else:
		Player._release()
	Dialogbox._close_dialog()

	
	
func _enter_crick():
	#set crickbed passable
	Crickbed.set_collision_mask(2)
	Crickbed.set_layer_mask(2)
	Bridge.set_z(1)
	Player.Aniplayer.set_speed(1)
	Player._climb_d()
	#wait for signal
	yield( Player, "DONE" )
	set_process( true )
	Player._release()
	#set crickbank impassable
	Crickbank.set_collision_mask(1)
	Crickbank.set_layer_mask(1)
	
	
func _leave_crick():
	#set crickbank passable
	Crickbank.set_collision_mask(2)
	Crickbank.set_layer_mask(2)
	Bridge.set_z(0)
	Player.Aniplayer.set_speed(1)
	Player._climb_u()
	#wait for signal
	yield( Player, "DONE" )
	set_process( true )
	Player._release()
	#set crickbed impassable
	Crickbed.set_collision_mask(1)
	Crickbed.set_layer_mask(1)
	
	


