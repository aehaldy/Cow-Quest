extends Node

onready var Player = get_node("Grid/Player")
onready var Dialogbox = get_node("Dialogbox/PanelContainer")
onready var bgm = load("res://Scenes/2Forest/forest_backmusic.ogg")

func _ready():
	Sound.stream(bgm, true)
	#Has to be a better way to handle this situation:
		#(Build it into Item_Object script?)
		#Combine NPC object and Item object?!)
	if not Globals.get("super_vine"):
		var Beanplant = get_node("Grid/Forest_Beanplant/AnimationPlayer")
		Beanplant.play('idle')
		
	if Globals.get("got_daisy"):
		get_node("Grid/Forest_Jack").queue_free()
		
	
	
	if not Globals.get("first_in_forest"):
		Globals.set("first_in_forest", true)
		Player._step_down() #Not sure what is happening with the stack & Dialogbox, that it runs before this...
		Player._turn_360() #Or why fixed process and can_move won't maintain their state without these first
		set_fixed_process(false)
		Player.can_move = false
		Dialogbox._set_dialog(0, 1, "Right. \nOff to find a [color=maroon]brown cow[/color]...", 
			"res://Scenes/Player/Player_Uncertain.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nFailure is not an option! ", 
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		#Player._step_down()
		Player._release()

