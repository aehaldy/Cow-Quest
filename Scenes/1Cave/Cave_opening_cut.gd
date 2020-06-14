extends Node

onready var Player = get_node("Grid/Player")
onready var bgm = load("res://Scenes/1Cave/CAVE_Zombie_Lounge_Mazedude.ogg")

func _ready():
	#Play the opening cut scene on new game
	if not Globals.get("opening_cut"):
		_opening_cut()
		Globals.set("opening_cut", true)
	else:
		Globals.set("talked_to_witch_bool",true)
		#set player starting position from here on out
		#Sound.stream(bgm)
		Player.set_pos( Vector2(576,1024) )
		Player._step_up()
		if Globals.get("got_daisy"):
			var Anicow = get_node("Grid/Brown_Cow/AnimationPlayer")
			Anicow.play("turn_u")
		#Sound.stream(bgm) #Door transition handles this

			
			

func _opening_cut():
	var Witch = get_node("Grid/Cave_Witch")
	var Cam = get_node("Grid/Player/Camera2D")
	var Dialogbox = get_node("Dialogbox/PanelContainer")
	var Aniplayer = Player.get_node("AnimationPlayer")
	
	#Freeze player
	Player.can_move = false
	Player.set_fixed_process(false)

	#pan cam to witch
	Cam._pan( Vector2(2,-4), 1 )
	yield( Cam, "CAM_PANNED" )
	#animate witch
	Sound._play_fx("jump")
	Witch._jump()
	yield( Witch, "DONE" )
	#run dialog
	Dialogbox._set_dialog(1, 1, "[center]Blast you, underling![/center]"\
		+ "\n\n\nWhere are you?", "res://Scenes/NPC/"\
		+ "Witch_Angry.tex", false)
	yield( Dialogbox, "next" )
	Dialogbox._set_dialog(1, 1, "You should know by now to "\
		+ "come when you're called.", "res://Scenes/NPC/Witch_Neutral.tex",
		false)
	yield( Dialogbox, "next" )
	Dialogbox._close_dialog()
	#Pan back to player
	Cam._pan_back( .75 )
	yield( Cam, "CAM_PANNED" )
	#animate balloon sprite on player
	get_node("Balloon")._balloon(Player.get_pos(), 'exclamation')
	#dialog
	Dialogbox._set_dialog(0, 1, "\nI must have dozed off for a minute...",
		"res://Scenes/Player/Player_Uncertain.tex", false)
	yield( Dialogbox, "next" )
	#Animate player
	Aniplayer.play("turn_r")
	#dialog
	Dialogbox._set_dialog(0, 1, "\nYes, Your Grand Ambivalence, "\
		+ "\nI'm coming!", "res://Scenes/Player/Player_Neutral.tex", 
		false)
	yield( Dialogbox, "next" )
	Dialogbox._close_dialog()
	#cue music
	Sound.stream(bgm)
	#Animate player
	Aniplayer.play("idle")
	#Give player instructions
	Dialogbox._set_dialog(1, 2, "Move using the Arrow Keys,"\
		+ " or [i]W, A, S, D[/i].\n\nHold [i]Shift[/i] to dash.", 
		null, false)
	yield( Dialogbox, "next" )
	Dialogbox._set_dialog(1, 2, "\nInteract with people and objects"\
		+" using [i]Enter[/i] or [i]Spacebar[/i].", 
		null, false)
	yield( Dialogbox, "next" )
	Dialogbox._close_dialog()
	#release the player
	Player._release()
	
	
	
