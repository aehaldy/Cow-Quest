extends Node

#==========================================================
#
#                     INSTRUCTIONS
#
#----------------------------------------------------------
#	1. Tree routes dialog to Dialogbox. 
#	The _set_dialog() function receives arguments:
#	( pos, skin, dialog, pic, end, choices)
#		* pos = 0 (bottom), 1 (middle), 2 (top) of screen
#		* skin = 0 (no stylebox), 1 (theme skin), 2 (shadow skin)
#		* dialog = Dialog text to display; uses BBCode, '\n' for newline.
#		* pic = resource path of face picture; defaults to null
#		* end = if this is the end of the dialog, defaults to true
#		* choices = List in string (parsed at ';'), defaults to null
#
#	2. BB Code Cheat Sheet
#		* Change Color: e.g., [color=purple]Dark Arts[/color]
#			COLORS: aqua, black, blue, fuchsia, gray, green, lime, 
#			maroon, navy, purple, red, silver, teal, white, yellow.
#		* Italics: e.g., [i]Dark Arts[/i]
#		* Center: e.g., [center] text [/center]

signal TIMER

var Interactor #Node with which player is interacting
var interactor_name
var Dialogbox 
var Player
var choice
var Delay #for timer

func _ready():
	pass
	
	
func _interaction(node, db, player_node):
	#link the Dialogbox node with script we need
	Interactor = node
	interactor_name = Interactor.get_name()
	Dialogbox = db
	Player = player_node
	
	#================================================
	# 	CAVE INTERACTABLES INDEX
	#================================================
	if interactor_name == "Cave_Witch":
		_cave_witch() 
	elif interactor_name == "Cave_Pouch":
		if not Globals.get("talked_to_witch_bool"):
			Globals.set("talked_to_witch_bool",false)
		_cave_pouch()
	elif interactor_name == "Cave_WorldMap":
		if not Globals.get("cave_worldmap_switch"):
			Globals.set("cave_worldmap_switch",0)
		_cave_worldmap()
	elif interactor_name == "Cave_SuperGro":
		if not Globals.get("cave_supergro_switch"):
			Globals.set("cave_supergro_switch",0)
		_cave_supergro()
	elif interactor_name == "Cave_Cabinet":
		if not Globals.get("moneybush_bool"):
			Globals.set("moneybush_bool",false)
		_cave_cabinet()
	elif interactor_name == "Cave_Gargoyle":
		_cave_gargoyle()
	elif interactor_name == "Cave_Kimchi":
		_cave_kimchi()
	elif interactor_name == "Cave_Crystal":
		_cave_crystal()
	elif interactor_name == "Cave_Bed":
		_cave_bed()
	elif interactor_name== "Cave_X_to_Forest":
		if not Globals.get("talked_to_witch_bool"):
			Globals.set("talked_to_witch_bool",false)
		_cave_x_to_forest()
	elif interactor_name == "":
		pass
		
	#================================================
	# 	FOEST INTERACTABLES INDEX
	#================================================
	elif interactor_name == "Forest_Door":
		_forest_door()
	elif interactor_name == "Forest_Well":
		_forest_well()
	elif interactor_name == "Forest_Warning":
		_forest_warning()
	elif interactor_name == "Forest_Signpost":
		_forest_signpost()
	elif interactor_name == "Forest_Fairy":
		_forest_fairy()
	elif interactor_name == "Forest_Beanplant":
		_forest_beanplant()
	elif interactor_name == "Forest_Market":
		_forest_market()
	elif interactor_name == "Forest_Dragons":
		_forest_dragons()
	elif interactor_name == "Forest_Jack":
		_forest_jack()
	elif interactor_name == "Forest_Cow":
		_forest_cow()
	else:
		return ERROR_QUERY_FAILED
		
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#	*   Here Be Ye Interaction Dialog Trees   *
#
#__________________________________________________________________

func _cave_witch():
	#stop witch movement, talk to player.
	Interactor._talk_to_player()
	#When player brings the brown cow
	if Globals.get("got_daisy") == true:
		Dialogbox._set_dialog( 0, 1, "Well?", 
			"res://Scenes/NPC/Witch_Neutral.tex", false )
		yield( Dialogbox, "next" )
		#Move camera up
		var Cam = Player.get_node("Camera2D")
		Cam._pan( Vector2(0,-1), .5)
		yield( Cam, "CAM_PANNED" )
		Dialogbox._set_dialog(0, 1, "\nO Contemplator of the Unthinkable Void,\n"\
			+ "I have done as you commanded.", "res://Scenes/Player/"\
			+ "Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\n	Behold!",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		#var Daisy = get_node("../Brown_Cow")
		#Daisy.Tweener.interpolate_property( self, 'transform/pos', pos, new_pos, 
		#			speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT )
		#Tweener.start() 
		Sound._play_fx('cow')
		Player._turn_360()
		yield( Player, "AnimTimer" )
		if Player.facing == "up":
			Player.Aniplayer.play("faced-2-faceu")
		elif Player.facing == "right":
			Player.Aniplayer.play("turn_r")
		elif Player.facing == "left":
			Player.Aniplayer.play("turn_l")
		Dialogbox._set_dialog(0, 1, "\n	The [color=maroon]Brown Cow[/color]!",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Cam._pan( Vector2(0,-1), .5)
		yield( Cam, "CAM_PANNED" )
		if Player.facing == "left":
			Interactor._jump_r()
		elif Player.facing == "right":
			Interactor._jump_l()
		else:
			Interactor._jump()
		yield( Interactor, "DONE" )
		Dialogbox._set_dialog( 2, 1, "\n	Splendid!", 
			"res://Scenes/NPC/Witch_Neutral.tex", false )
		#Sound.fadeout()
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog( 2, 1, "\nNow you can learn the greatest\n"\
			+ "transmutation spell of all, and create...", 
			"res://Scenes/NPC/Witch_Neutral.tex", false )
		var ending_music = load("res://Scenes/Credits/Get_on_the_Bus.ogg")
		yield( Dialogbox, "next" )
		Sound.stream(ending_music, false)
		Dialogbox._set_dialog( 2, 1, "\n	[i]Chocolate Milk!![/i]", 
			"res://Scenes/NPC/Witch_Neutral.tex", false )
		yield( Dialogbox, "next" )
		Transition.fade_to("res://Scenes/Credits/Credits.tscn")
		
		
	#Until get brown cow:
	elif Globals.get("talked_to_witch_bool") == true:
		Dialogbox._set_dialog( 0, 1, "Well?\nHave you found "\
			+ "a brown cow?", "res://Scenes/NPC/Witch_Neutral.tex",
			false )
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Interactor._resume_move()
		Player._release()
	#
	else:
		#Move camera up
		var Cam = Player.get_node("Camera2D")
		Cam._pan( Vector2(0,-2), .5)
		yield( Cam, "CAM_PANNED" )
		#Animate witch
		if Player.facing == "left":
			Interactor._jump_r()
		elif Player.facing == "right":
			Interactor._jump_l()
		else:
			Interactor._jump()
		yield( Interactor, "DONE" )
		Dialogbox._set_dialog(2, 1, "There you are! \n\n"\
			+ "Quit dragging your heels.", "res://Scenes/NPC/"\
			+ "Witch_Angry.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "How can I serve you, "\
			+ "Most Witching One?", "res://Scenes/Player/"\
			+ "Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "I have determined that it's time "\
			+ "to teach you the first Great Transmutation Spell.", 
			"res://Scenes/NPC/Witch_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "Truly, your Magicalness?",
			"res://Scenes/Player/Player_Uncertain.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nI swear to master it!",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nYes, well...", 
			"res://Scenes/NPC/Witch_Angry.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "Before you can learn it,\n"\
			+ "you must bring back the most vital spell component.", 
			"res://Scenes/NPC/Witch_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nAnd what's that, O Darkest of Nights?", 
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\n	A cow.", 
			"res://Scenes/NPC/Witch_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\n	What?",
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "Specifically, a [color=maroon]"\
			+ "brown cow[/color].\n\nNo other kind will do.", 
			"res://Scenes/NPC/Witch_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "But where can I find a "\
			+ "[color=maroon]brown cow[/color]?",
			"res://Scenes/Player/Player_Uncertain.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nThe market, perhaps?", 
			"res://Scenes/NPC/Witch_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "Oh, yes. Of course.\n\n"\
			+ "[center]So then...[/center]", 
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nCan I have some money?",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "I'm a witch, not a bank!\n"\
			+ "If you can't figure out how to bring back a brown cow,"\
			+ " you'd best not come back at all.", 
			"res://Scenes/NPC/Witch_Angry.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "Er, yes, Your Terrifyingness!"\
			+ "\n\nIt shall be done.",
			"res://Scenes/Player/Player_Uncertain.tex", false)
		yield( Dialogbox, "next" )
		Globals.set("talked_to_witch_bool", true)
		#Move camera down
		Cam._pan_back(.5)
		Dialogbox._close_dialog()
		#yield( Cam, "CAM_PANNED" )
		Interactor.can_move = true
		Interactor.talking = false
		Player._step_down()
		Interactor._get_pattern(Interactor)
		
		
func _cave_pouch():
	#===================================================
	#	**	Dialog Setting Key	**
	#	( pos, 0=bottom, 1=middle, 2=top
	#	skin, 0=none, 1=theme, 2=shadow
	#	dialog, pic, end bool, choices)
	#===================================================
	if Globals.get("talked_to_witch_bool") == true:
		Dialogbox._set_dialog(2, 1, "\nHere's my money pouch!","res:"\
			+ "//Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog( 2, 1, "\n...Unfortunately, it's "\
			+ "empty.","res://Scenes/Player/Player_Uncertain.tex", 
			false )
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog( 1, 2, null, null, false, 
			"Take the empty pouch.;Leave it." )
		yield( Dialogbox, "next" )
		choice = Dialogbox.selection
		if choice == 0:
			#Prevent further interaction with the Interactor:
			Globals.hidden_group.append( interactor_name )
			Globals.inactive_group.append( interactor_name )
			#Proces Item_Object to Inventory:
			Interactor._collect_item('Pouch')
			#Play SE 
			Sound._play_fx("item")
			Dialogbox._set_dialog( 1, 2, "\n[center][i]Got Pouch![/i][/center]" )
			if not Globals.get("first_inventory"):
				Inventory.hidden = false
				Dialogbox._set_dialog( 1, 2, "Notice your [i]Inventory[/i] "\
					+ "in the upper right corner.\n\nYou can toggle the display"\
					+ " off and on using the [i]X[/i] button.")
				Globals.set("first_inventory", true)
		else:
			Dialogbox._close_dialog()
			Player._release()
	else:
		Dialogbox._set_dialog(2, 1, "I can sort my things later."\
			+ "\n\nThe Witch just called me, and that doesn't "
			+ "happen every day.", "res://Scenes/Player/Player_Neutral.tex")
			
		
func _cave_x_to_forest():
	#Need player for this interaction
	#===================================================
	#	**	Dialog Setting Key	**
	#	( pos, 0=bottom, 1=middle, 2=top
	#	skin, 0=none, 1=theme, 2=shadow
	#	dialog, pic, end bool, choices)
	#===================================================
	if Globals.get("got_daisy") == true:
		Dialogbox._set_dialog(2, 1, "\nI'm eager to show The Witch this brown cow!",
			"res://Scenes/Player/Player_Grin.tex", false)
		#Add next "dialog" event 
		yield( Dialogbox, "next" )
		#Turns player sprite around and faces up again.
		Dialogbox._close_dialog()
		Player._step_up(1)
	elif Globals.talked_to_witch_bool == true:
		Sound._play_fx("map_transition")
		Transition.fade_to("res://Scenes/2Forest/Forest.tscn")
		var bg_music = load( "res://Scenes/2Forest/forest_backmusic.ogg" )
		Sound.crossfade(bg_music, true)
	else:
		Dialogbox._set_dialog(2, 1, "The Witch called me. "\
			+ "I'd better not leave before seeing her.","res:"\
			+ "//Scenes/Player/Player_Uncertain.tex", false)
		#Add next "dialog" event 
		yield( Dialogbox, "next" )
		#Turns player sprite around and faces up again.
		Dialogbox._close_dialog()
		Player._step_up(1)
		
		
func _cave_worldmap():
	#===================================================
	#	**	Dialog Setting Key	**
	#	( pos, 0=bottom, 1=middle, 2=top
	#	skin, 0=none, 1=theme, 2=shadow
	#	dialog, pic, end bool, choices)
	#===================================================
	if Globals.get("cave_worldmap_switch") == 0:
		Dialogbox._set_dialog( 0, 1, "This is a map of the "\
			+ "known world, which I shall set out to conquer"\
			+ " once I've mastered the \n[i]Dark Arts[/i].", "res:"\
			+ "//Scenes/Player/Player_Neutral.tex")
		Globals.set("cave_worldmap_switch",1)
		
	elif Globals.get("cave_worldmap_switch") == 1:
		Dialogbox._set_dialog(0, 1, "Soon... \n\n		Soon."\
			+ "\n\n				Muahahahaa...!", "res://Scenes/"\
			+ "Player/Player_Grin.tex")
		

func _cave_supergro():
	#===================================================
	#	**	Dialog Setting Key	**
	#	( pos, 0=bottom, 1=middle, 2=top
	#	skin, 0=none, 1=theme, 2=shadow
	#	dialog, pic, end bool, choices)
	#===================================================
	if Globals.cave_supergro_switch == 4:
		Dialogbox._set_dialog(0, 1,"I don't need any more [i]SuperGro[/i](tm).",
			"res://Scenes/Player/Player_Neutral.tex")
			
	elif ( Globals.inventory['Bottle']['qty'] > 0 
		&& Globals.get("moneybush_bool") == true 
		&& Globals.cave_supergro_switch > 0 ):
		Dialogbox._set_dialog(0, 1,"I can fill this potion bottle with "\
			+ "[i]SuperGro[/i](tm) water.",
		"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog( 2, 2, null, null, false, 
			"Fill the bottle.;Nah. I like empty bottles." )
		yield( Dialogbox, "next" )
		choice = Dialogbox.selection
		if choice == 0:
			Interactor._remove_item( 'Bottle' )
			Interactor._collect_item( 'SuperGro' )
			Sound._play_fx('item')
			Dialogbox._set_dialog( 2, 2, "\n[center][i]Got SuperGro(tm)![/i][/center]" )
			Globals.cave_supergro_switch = 4
		else:
			Dialogbox._close_dialog()
			Player._release()
			
	elif ( Globals.get("moneybush_bool") 
		&& Globals.cave_supergro_switch > 0 ):
		Dialogbox._set_dialog(0, 1,"I wonder if [i]SuperGro[/i](tm) would make the"\
			+ " money seedling mature enough to produce it's lucrative fruit?"\
			+ "\n\nBut I can't take the whole bucket...",
			"res://Scenes/Player/Player_Neutral.tex")
			
	elif Globals.cave_supergro_switch == 3:
		Dialogbox._set_dialog(0, 1, "The Witch would be furious if I gave out "\
			+ "her secret magic potion.", "res://Scenes/Player/Player_Uncertain.tex")
			
	elif ( Globals.cave_supergro_switch > 0 
		&& Globals.get("met_jack_bool") ):
		Dialogbox._set_dialog(0, 1, "[i]SuperGro[/i](tm) water [i]is[/i] valuable."\
		+ "\nBut there's no way The Witch would let me give out her secret potion.",
		"res://Scenes/Player/Player_Uncertain.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "That said, it would probably be alright for me "\
			+ "to use a just little for myself. [i]Hmm...[/i]", 
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1,"Perhaps I could grow Jack a giant pumpkin?\n\n",
			"res://Scenes/Player/Player_Neutral.tex")
		Globals.cave_supergro_switch = 3
		
	elif Globals.cave_supergro_switch == 2:
		Dialogbox._set_dialog(0, 1, "[i]SuperGro[/i](tm) can't help me find "\
			+ "a [color=maroon]brown cow[/color]", "res://Scenes/Player/Player_Neutral.tex")
			
	elif ( Globals.cave_supergro_switch == 1 
		&& Globals.get("talked_to_witch_bool") == true ):
		Dialogbox._set_dialog(0, 1, "The Witch uses hasn't taught me how to "\
			+ "make [i]SuperGro[/i](tm)...", 
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "--yet! \n\nAfter this new spell "\
			+ "I'm about to learn, I'll be well on my way! [i]Mua ha[/i]!", 
			"res://Scenes/Player/Player_Grin.tex")
		Globals.cave_supergro_switch = 2
		
	else:
		Dialogbox._set_dialog(0, 1, "This is The Witch's enchanted "\
			+ "[i]SuperGro[/i](tm) water. She uses it to quickly harvest "\
			+ "mystical herbs without having to wait the full growth cycle.", 
			"res://Scenes/Player/Player_Neutral.tex")
		Globals.cave_supergro_switch = 1
	

func _cave_cabinet():
	#===================================================
	#	**	Dialog Setting Key	**
	#	( pos, 0=bottom, 1=middle, 2=top
	#	skin, 0=none, 1=theme, 2=shadow
	#	dialog, pic, end bool, choices)
	#===================================================
	if Globals.moneybush_bool == true:
		Dialogbox._set_dialog(0, 1, "Here's that old potion bottle.\n"\
			+ "Might come in handy.", "res://Scenes/Player/"\
			+ "Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		#Update the Interactors status in prep
		Globals.inactive_group.append( interactor_name )
		Globals.static_frame[interactor_name] = 1
		#Proces Item_Object to Inventory:
		Interactor._collect_item( 'Bottle' )
		Sound._play_fx('item')
		Dialogbox._set_dialog( 2, 2, "\n[center][i]Got Bottle![/i][/center]" )
		if not Globals.get("first_inventory"):
				Inventory.hidden = false
				Dialogbox._set_dialog( 1, 2, "Notice your [i]Inventory[/i] "\
					+ "in the upper right corner.\n\nYou can toggle the display"\
					+ " off and on using the [i]X[/i] button.")
				Globals.set("first_inventory", true)
	else:
		Dialogbox._set_dialog(0, 1, "Let's see... "\
			+ "There's some dishes, towels, and an old potion bottle..."\
			+ " Nothing valuable, though.", "res://Scenes/Player/"\
			+ "Player_Neutral.tex")

		
		
func _cave_kimchi():
	if Globals.get("moneybush_bool") == true:
		Dialogbox._set_dialog(0, 1, "If The Witch's magic didn't ward off bears,"\
			+ " this kimchi would. ", "res://Scenes/Player/Player_Neutral.tex")
	elif Globals.get("met_jack_bool") == true:
		Dialogbox._set_dialog(0, 1, "I don't think Jack would trade "\
			+ "his cow for vile kimchi.", "res://Scenes/Player/Player_Neutral.tex")
	else:
		Dialogbox._set_dialog(0, 1, "That jar of kimchi smells positively evil.", 
		"res://Scenes/Player/Player_Angry.tex")
		
		
func _cave_gargoyle():
	Dialogbox._set_dialog(0, 1, "\nI swear it's eyes are following me...", 
		"res://Scenes/Player/Player_Neutral.tex")
		
		
func _cave_crystal():
	if Globals.get("cave_crystal_switch") == 1:
		Dialogbox._set_dialog(0, 1, "I don't have a death wish.",
		"res://Scenes/Player/Player_Uncertain.tex")
	else:
		Dialogbox._set_dialog(0, 1, "The Witch has made it clear "\
			+ "what would happen if I touched her Crystal Ball, starting "\
			+ "with my eyes bursting into flame and ending as a flayed frog.",
			"res://Scenes/Player/Player_Neutral.tex")
		Globals.set("cave_crystal_switch", 1)
		
		
func _cave_bed():
	Dialogbox._set_dialog(0, 1, "I assume that's The Witch's bed. "\
		+ "\n\nShe never seems to sleep, though.",
		"res://Scenes/Player/Player_Neutral.tex")
		
		
#==================================================
#
# 		Here be ye FOREST Interactables!
#
#=================================================
	
func _forest_door():
	if Player.facing == "up":
		#This is hackish sound implementation--streamline later:
		var bg_music = load("res://Scenes/1Cave/CAVE_Zombie_Lounge_Mazedude.ogg")
		Sound.crossfade(bg_music, true)
		Interactor._enter_door("res://Scenes/1Cave/Cave.tscn") 
	else:
		Player._release()
	
	
func _forest_well():
	Dialogbox._set_dialog(2, 1, "It's not a wishing well.\n"\
		+ "There's no [color=maroon]brown cow[/color] down there.", 
		"res://Scenes/Player/Player_Neutral.tex")
	
	
func _forest_warning():
	Dialogbox._set_dialog(2, 2, "\n[center][i]Trespassers will be frogged![/i][/center]",
		null)
		
		
func _forest_signpost():
	Dialogbox._set_dialog(2, 2, "\n[center][i]<- Market \n\nDragons "\
		+ "->[/i][/center]", null)
	
	
func _forest_fairy():
	#===================================================
	#	**	Dialog Setting Key	**
	#	( pos, 0=bottom, 1=middle, 2=top
	#	skin, 0=none, 1=theme, 2=shadow
	#	dialog, pic, end bool, choices)
	#===================================================
	var Sparkles = get_node("/root/Forest/Grid/Sparkle")
	
	if ( Globals.get("talked_to_fairy") == true
		&& Globals.inventory['Sparkle Beans']['qty'] > 0 ):
		Player._step_left()
		Dialogbox._set_dialog(0, 1, "I'm never talking to the fairy again.", 
			"res://Scenes/Player/Player_Angry.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Player.Aniplayer.play("idle")
		yield( Player, "AnimTimer" )
		Dialogbox._set_dialog(0, 1, "\nUnless I need something sparkly.", 
			"res://Scenes/Player/Player_Neutral.tex")
			
	elif ( Globals.get("talked_to_fairy") == true
		&& Globals.inventory['Bean Pouch']['qty'] > 0 ):
		Dialogbox._set_dialog(2, 2, "Wait! I have an idea...", 
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 2,null,null,false,"Take the beans out, "\
			+ "then talk to the fairy.; ...Nevermind. Just talk to the fairy.")
		yield( Dialogbox, "next" )
		choice = Dialogbox.selection
		if choice == 0:
			Globals.inventory['Bean Pouch']['qty'] -= 1
			Inventory._update_inventory()
			var Beans = get_node("/root/Forest/Grid/Sparklebeans")
			Player._step_left(1,false)
			_activate_timer( .4 )
			yield( self, "TIMER" )
			Sound._play_fx("beandrop")
			Beans.show()
			Player._step_right(1,false)
			_activate_timer( .7 )
			yield( self, "TIMER" )
			Interactor.Aniplayer.play('face_l')
			Dialogbox._set_dialog(0, 1, "\nSPARKLES!", 
				"res://Scenes/NPC/Fairy_Face.tex", false)
			yield( Dialogbox, "next" )
			Dialogbox._close_dialog()
			Interactor.Aniplayer.play("magic_l")
			yield( Interactor, "DONE" )
			_activate_timer( .3 )
			yield( self, "TIMER" )
			Player._jump_back(1)
			yield( Player, "DONE" )
			Sparkles.set_pos(Vector2(2964,1216))
			Sparkles.set_emit_timeout(3)
			yield( Player, "DONE" ) #two signals to complete jump
			Player._step_back(1,false)
			Beans.get_node("AnimationPlayer").play("sparkle")
			_activate_timer( .5 )
			yield( self, "TIMER" )
			Interactor._fairy_magic_u()
			Player.set_fixed_process(false)
			_activate_timer( .3 )
			yield( self, "TIMER" )
			Dialogbox._set_dialog(0, 1, "\n Yes. The beans are sparkling.", 
			"res://Scenes/Player/Player_Neutral.tex", false)
			yield( Dialogbox, "next" )
			Dialogbox._close_dialog()
			Player._step_right(1,false)
			Globals.inventory['Sparkle Beans']['qty'] += 1
			Inventory._update_inventory()
			Sound._play_fx('item')
			Dialogbox._set_dialog( 2, 2, "\n[center][i]Got Sparkly Beans![/i][/center]" )
			Beans.hide()
		else:
			Interactor.Aniplayer.play('face_l')
			Dialogbox._set_dialog(0, 1, "\nSPARKLES!", 
				"res://Scenes/NPC/Fairy_Face.tex", false)
			yield( Dialogbox, "next" )
			Dialogbox._close_dialog()
			Interactor.Aniplayer.play("magic_l")
			yield( Interactor, "DONE" )
			_escape_fairy()
			
	elif ( Globals.get("talked_to_fairy") == true
		&& Globals.inventory['Bottle']['qty'] > 0 ):
		Interactor.Aniplayer.play('face_l')
		Dialogbox._set_dialog(0, 1, "\nSPARKLES!", 
			"res://Scenes/NPC/Fairy_Face.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Interactor.Aniplayer.play("magic_l") 
		yield( Interactor, "DONE" )
		_activate_timer( .3 )
		yield( self, "TIMER" )
		Player._jump_back(1)
		yield( Player, "DONE" )
		Sparkles.set_pos(Vector2(2964,1216))
		Sparkles.set_emit_timeout(3)
		yield( Player, "DONE" ) #two signals to complete jump
		Player._step_back(1,false)
		_activate_timer( .5 )
		yield( self, "TIMER" )
		Player.Aniplayer.play("idle")
		Interactor._fairy_magic_u()
		_activate_timer( .3 )
		yield( self, "TIMER" )
		Dialogbox._set_dialog(0, 1, "A shame that pesky fairy is too big "\
			+ "to catch in my bottle.", "res://Scenes/Player/Player_Angry.tex")
			
	elif Globals.get("talked_to_fairy") == true:
		Interactor.Aniplayer.play('face_l')
		Dialogbox._set_dialog(0, 1, "\nSPARKLES!", 
			"res://Scenes/NPC/Fairy_Face.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Interactor.Aniplayer.play("magic_l")
		yield( Interactor, "DONE" )
		_escape_fairy()
		
	else:
		Interactor.get_node("Interaction").set_process_input( false )
		Sound._play_fx("sparkles")
		Interactor._fairy_magic_particles()
		Interactor.Aniplayer.play("face_u")
		Dialogbox._set_dialog(2, 1, "\nWeee!", 
			"res://Scenes/NPC/Fairy_Face.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		_activate_timer( .5 )
		yield( self, "TIMER" )
		Interactor.Aniplayer.play("face_l")
		var Balloon = get_node("/root/Forest/Balloon")
		Balloon._balloon(Vector2(3104,1248), 'exclamation')
		_activate_timer( .3 )
		yield( self, "TIMER" )
		Dialogbox._set_dialog(2, 1, "Oh! You startled me!", 
			"res://Scenes/NPC/Fairy_Face.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nAre you here to fight?", 
			"res://Scenes/NPC/Fairy_Face.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "No.\n"\
			+ "\nI'm looking for a [color=maroon]brown cow[/color].", 
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nAre you a princess?", 
			"res://Scenes/NPC/Fairy_Face.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\n	No!", 
			"res://Scenes/Player/Player_Angry.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nCan I make you sparkly?", 
			"res://Scenes/NPC/Fairy_Face.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\n	What?", 
			"res://Scenes/Player/Player_Uncertain.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\n	Yay!", 
			"res://Scenes/NPC/Fairy_Face.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Interactor.Aniplayer.play("magic_l")
		yield( Interactor, "DONE" )
		var Flash = get_node("/root/Forest/FlashLayer")
		_activate_timer( .4 )
		yield( self, "TIMER" )
		Player._jump_back(1)
		Flash._yellow_flash()
		#sparkles on player
		Sparkles.set_pos(Vector2(3008,1216))
		yield( Player, "DONE" )
		Sparkles.set_pos(Vector2(2944,1216))
		yield( Player, "DONE" ) #two signals to complete jump
		Player._step_back(1,false)
		Sparkles.set_pos(Vector2(2880,1216))
		Interactor.Aniplayer.play("face_l")
		Balloon._balloon(Vector2(2912,1248), 'exclamation')
		yield(Balloon, "BALLOON_POP")
		Dialogbox._set_dialog(2, 1, "I love making things sparkly!", 
			"res://Scenes/NPC/Fairy_Face.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Player.set_fixed_process(false)
		Player.Aniplayer.play("idle")
		yield( Player, "AnimTimer" )
		Balloon._balloon(Player.get_pos(), 'teardrop')
		yield(Balloon, "BALLOON_POP")
		Interactor.Aniplayer.play("face_u")
		Dialogbox._set_dialog(2, 1, "Unfortunately for that foolish fairy, "\
			+ "I possess the power to break this sparkly spell!",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 0, "\n[center][i]Petalumin Nullicus![/i][/center]",
			"res://Scenes/Player/Player_Angry.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Sound._play_fx("bumerang")
		Player._turn_360(2)
		Flash._shadow_pulse()
		Sparkles.set_emitting(false)
		yield (Player, "DONE" )
		Player.Aniplayer.play("idle")
		Interactor._fairy_magic_u()
		_activate_timer( 1 )
		yield( self, "TIMER" )
		Player.Aniplayer.play("turn_l")
		Player._release()
		Globals.set("talked_to_fairy", true)
		
func _escape_fairy():
	var Sparkles = get_node("/root/Forest/Grid/Sparkle")
	_activate_timer( .2 )
	yield( self, "TIMER" )
	Player._jump_back(1)
	yield( Player, "DONE" )
	Sparkles.set_pos(Vector2(2964,1216))
	Sparkles.set_emit_timeout(2.5)
	yield( Player, "DONE" ) #two signals to complete jump
	Player._step_back(1,false)
	_activate_timer( .5 )
	yield( self, "TIMER" )
	Interactor._fairy_magic_u()
	Player.set_fixed_process(false)
	Player.Aniplayer.play("idle")
	yield( Player, "AnimTimer" )
	Dialogbox._set_dialog(0, 1, "Why am I trying to talk to a fairy?", 
		"res://Scenes/Player/Player_Angry.tex")
	
	
func _forest_beanplant():
	var Anibean = Interactor.get_node("AnimationPlayer")
	#===================================================
	#	**	Dialog Setting Key	**
	#	( pos, 0=bottom, 1=middle, 2=top
	#	skin, 0=none, 1=theme, 2=shadow
	#	dialog, pic, end bool, choices)
	#===================================================
	if not Globals.get("moneybush_bool"):
		var Balloon = get_node("/root/Forest/Balloon")
		Dialogbox._set_dialog(2, 1, "A strange plant has taken root "\
			+ "in the dry riverbed...", "res://Scenes/Player/Player_Neutral.tex", 
			false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Balloon._balloon(Player.get_pos(), 'exclamation')
		yield( Balloon, "BALLOON_POP" )
		Dialogbox._set_dialog(2, 1, "\nWait, I think this is...",
			"res://Scenes/Player/Player_Uncertain.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "Look at the sinewy stem.\n\n"\
			+ "Yes, this is a Money Tree seedling!",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nToo bad it won't bear fruit for many years.",
			"res://Scenes/Player/Player_Neutral.tex")
		Globals.set("moneybush_bool", true)
		
	elif (Globals.inventory['Bean Pouch']['qty'] > 0 or 
		Globals.inventory['Sparkle Beans']['qty'] > 0):
		Dialogbox._set_dialog(2, 1, "\nI'm already full of beans.",
			"res://Scenes/Player/Player_Neutral.tex")
			
	elif Globals.get("super_vine"):
		Dialogbox._set_dialog(2, 1, "It looks like the vine has seed pods.",
			"res://Scenes/Player/Player_Uncertain.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nNo, they're beans...",
			"res://Scenes/Player/Player_Neutral.tex", false )
		yield( Dialogbox, "next" )
		
		if ( Globals.inventory['Pouch']['qty'] > 0 ):
			Dialogbox._close_dialog()
			Anibean.play('touch')
			Interactor._collect_item('Bean Pouch')
			Interactor._remove_item('Pouch')
			_activate_timer( .3 )
			yield( self, "TIMER" )
			Sound._play_fx('item')
			Dialogbox._set_dialog( 2, 2, "\n[center][i]Got Beans![/i][/center]" )
		else:
			Dialogbox._set_dialog(2, 1, "\nBut I need a bag or something "\
			+ "if I want to harvest them.",
			"res://Scenes/Player/Player_Neutral.tex")
			
	elif ( Globals.inventory['SuperGro']['qty'] > 0 ):
		var Flash = get_node("/root/Forest/FlashLayer")
		Dialogbox._set_dialog(2, 1, "Just maybe... \n\n"\
			+ "this SuperGro(tm) will make the money tree bear fruit!",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Interactor._remove_item('SuperGro')
		Interactor._collect_item('Bottle')
		Sound._play_fx( 'water' )
		Anibean.play( 'transform' )
		_activate_timer( .6 )
		yield( self, "TIMER" )
		Sound._play_fx( 'whoosh' )
		_activate_timer( .3 )
		yield( self, "TIMER" )
		Flash._blue_flash()
		_activate_timer( 1 )
		yield( self, "TIMER" )
		Dialogbox._set_dialog(2, 1, "Huh?\nThis is no money tree...!",
			"res://Scenes/Player/Player_Uncertain.tex", false)
		yield( Dialogbox, "next" )
		Globals.set("super_vine", true)
		Globals.static_frame[interactor_name] = 10
		Dialogbox._set_dialog(2, 1, "\nIt's just some dumb vine.",
			"res://Scenes/Player/Player_Angry.tex")
		
	elif Globals.get("met_jack_bool"):
		Dialogbox._set_dialog(2, 1, "If only this money tree was more mature."\
			+ "\n\n	I could buy ten [color=maroon]brown cows[/color]",
		 	"res://Scenes/Player/Player_Neutral.tex")
		
	else:
		Dialogbox._set_dialog(2, 1, "Even if this [i]is[/i] a young Money Tree,\n"\
			+ "	it won't bear fruit for many years.",
		 	"res://Scenes/Player/Player_Neutral.tex")
		
		
func _forest_market():
	if Globals.get("got_daisy"):
		Dialogbox._set_dialog(2, 1, "No need to go to market now."\
			+ "\n\n	I have my cow!",
		 	"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Player._step_up()
	elif Globals.get("met_jack_bool"):
		Dialogbox._set_dialog(2, 1, "No, if I have to go all the way to market "\
			+ "to find something to trade Jack, he might be gone by the time I "\
			+ "get back, and who knows if I'll find another [color=maroon]brown cow[/color].",
		 	"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nThere must be something around here I can trade him...",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Player._step_up()
	else:
		Dialogbox._set_dialog(2, 1, "Yes, this is the way to market.\n"\
			+ "But there's no point going if I have nothing to barter with.",
		 	"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Player._step_up()
	
func _forest_dragons():
	if Globals.get("got_daisy"):
		Dialogbox._set_dialog(0, 1, "I can't waste time wandering around!"\
			+ "\n\n	I need to show The Witch my cow.",
		 	"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Player._step_down()
	else:
		Dialogbox._set_dialog(0, 1, "	There's nothing up north I want to see\n"\
			+ "--especially dragons.",
		 	"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Player._step_down()
		
		
func _forest_jack():
	#stop Jack's movement, talk to player.
	Interactor._talk_to_player()
	#===================================================
	#	**	Dialog Setting Key	**
	#	( pos, 0=bottom, 1=middle, 2=top
	#	skin, 0=none, 1=theme, 2=shadow
	#	dialog, pic, end bool, choices)
	#===================================================
	if not Globals.get("jack_counter"):
		Dialogbox._set_dialog(0, 1, "Hello, young man."\
			+ "\n	Fine cow you have there.",
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nThanks. She's my best friend, Daisy",
			"res://Scenes/NPC/Jack_Happy.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nHow...sweet.",
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nYeah. Unfortunately, I have to sell her.",
			"res://Scenes/NPC/Jack_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nReally now?",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "Mom said we're totally broke,\n"\
			+ "so have to take her to market.",
			"res://Scenes/NPC/Jack_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nIt's still a long way to market...",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "I know, but I'm not in a hurry "\
			+ "to say goodbye.",
			"res://Scenes/NPC/Jack_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nAnd this might be the last time "\
			+ "Daisy gets to eat her fill!",
			"res://Scenes/NPC/JackSad.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "Okay, don't cry.\n\n\n		Tell you what. ",
			"res://Scenes/Player/Player_Uncertain.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nI'll take Daisy and give her a good home.",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\n		You will?",
			"res://Scenes/NPC/Jack_Excited.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nSure! Hand her over.",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nHow much?",
			"res://Scenes/NPC/Jack_Happy.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\n	What?",
			"res://Scenes/Player/Player_Uncertain.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nWill you pay?",
			"res://Scenes/NPC/Jack_Happy.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "Well, I'll pay...",
			"res://Scenes/Player/Player_Neutral.tex", false,
			"50 Gold!;10 kisses!;My good deed is enough.")
		yield( Dialogbox, "next" )
		choice = Dialogbox.selection
		if choice == 0:
			Dialogbox._set_dialog(2, 1, "\n		It's a deal!",
				"res://Scenes/NPC/Jack_Excited.tex", false)
			yield( Dialogbox, "next" )
			Dialogbox._set_dialog(0, 1, "\n	...as an IOU.",
				"res://Scenes/Player/Player_Neutral.tex", false)
			yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "Sorry, I promised Mom I'd come back "\
			+ "with no less than 12 silver.",
			"res://Scenes/NPC/Jack_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nYou have to give me money, "\
			+ "or something I can trade for money.",
			"res://Scenes/NPC/Jack_Neutral.tex")
		Globals.set("jack_counter", 1)
		Globals.set("met_jack_bool",true)
		
	elif ( Globals.jack_counter > 0
		&& Globals.inventory['Sparkle Beans']['qty'] > 0 ):
		Dialogbox._set_dialog(0, 1, "Perhaps you'd be willing to trade "\
			+ "Daisy for these enchanted Beans of Power?!",
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nJust [i]look[/i] at the magic.",
			"res://Scenes/Player/Player_Grin.tex", false)
		#show inventory
		Inventory.hidden = false
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\n	Oooooo...!",
			"res://Scenes/NPC/Jack_Excited.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "That's right!\n\n"\
			+ "	They're worth a fortune.",
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nSo what do you say?",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "Those really [i]are[/i] magic beans, "\
			+ "aren't they?", "res://Scenes/NPC/Jack_Happy.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "Of course.\n\n"\
			+ "	Do I look like a liar?",
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\n		. . .",
			"res://Scenes/NPC/Jack_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "Well, this is my final offer.\n\n"\
			+ "Magic Beans in exchange for Daisy.",
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\n\n    Going once...\n",
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\n	Sold!",
			"res://Scenes/NPC/Jack_Excited.tex", false)
		yield( Dialogbox, "next" )
		Globals.inventory['Sparkle Beans']['qty'] -= 1
		Inventory._update_inventory()
		Sound._play_fx('fanfare')
		Dialogbox._set_dialog( 1, 2, "\n[center][color=fuchsia][i]Got Daisy the Brown Cow!!![/i][/color][/center]",
			 null, false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "	Thanks, Mister!\n\nI can't wait to "\
			+ "show my mom these magic beans! ",
			"res://Scenes/NPC/Jack_Excited.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Interactor._turn('l')
		_activate_timer( .5 )
		yield( self, "TIMER" )
		Dialogbox._set_dialog(2, 1, "\n    Daisy, I love you!\n\n        Be good!",
			"res://Scenes/NPC/JackSad.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Interactor.can_move = true
		Interactor.speed = .5
		Interactor._step_l(2)
		yield(Interactor, "DONE" )
		Interactor.hide()
		var anim = Player.anim
		#Player turn down
		Dialogbox._set_dialog(0, 1, "\n	Heh, heh, heh...\n"\
			+ "	Victory is mine!",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		#Player face Daisy
		var Aniplayer = Player.get_node("AnimationPlayer")
		Aniplayer.play(anim)
		Dialogbox._set_dialog(0, 1, "\n	Come, Daisy.",
				"res://Scenes/Player/Player_Neutral.tex", false)
		Aniplayer.stop()
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		var Daisy = get_node("/root/Forest/Grid/Brown_Cow")
		var Anicow = Daisy.get_node("AnimationPlayer")
		Anicow.play('get_daisy')
		Sound._play_fx('cow')
		_activate_timer( 1 )
		yield( self, "TIMER" )
		Player.cow_pos = Vector2(160, 1248)
		Globals.set("got_daisy", true)
		Daisy.set_fixed_process(true)
		Player._release()
		
		
	elif ( Globals.jack_counter == 2
		&& Globals.inventory['Bean Pouch']['qty'] > 0 ):
		Dialogbox._set_dialog(0, 1, "Perhaps you'd be willing to trade "\
			+ "Daisy for these mysterious beans?!",
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nBeans? You're joking, right?",
			"res://Scenes/NPC/Jack_Happy.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nThey're [i]MAGIC Beans[/i].",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\n	Really?",
			"res://Scenes/NPC/Jack_Excited.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\n	Yessssss.",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nBut they don't look magic.",
			"res://Scenes/NPC/Jack_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nSilly boy. Looks are deceiving.",
				"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "\nWhat do they do?",
			"res://Scenes/NPC/Jack_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\n		Magic...",
				"res://Scenes/Player/Player_Uncertain.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(2, 1, "...Nah. I can't.\n\n "\
			+ "I'm pretty sure they're just beans.",
			"res://Scenes/NPC/Jack_Happy.tex", false)
		yield( Dialogbox, "next" )
		Player.Aniplayer.play('idle')
		_activate_timer( .3 )
		yield( self, "TIMER" )
		Dialogbox._set_dialog(0, 2, "	Drat!\n\nI was sure that would work,"\
			+ "\nfor some reason.",
			"res://Scenes/Player/Player_Angry.tex")
		Globals.set("jack_counter", 3)
	
	elif ( Globals.jack_counter == 1 ):
		Dialogbox._set_dialog(2, 1, "I'll have to go to market soon,\n"\
			+ "so if you want to buy Daisy, you better rustle up "\
			+ "some proper payment, fast.",
			"res://Scenes/NPC/Jack_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		#Save Jack's current animation for reuse
		var jackfacing = Interactor.Aniplayer.get_current_animation()
		Interactor.Aniplayer.play("face_l")
		_activate_timer( .4 )
		yield( self, "TIMER" )
		Dialogbox._set_dialog(2, 1, "\n	Now eat up, Buttercup!",
			"res://Scenes/NPC/Jack_Happy.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\nI thought her name was Daisy.",
			"res://Scenes/Player/Player_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		_activate_timer( .4 )
		yield( self, "TIMER" )
		Interactor.Aniplayer.play(jackfacing)
		Dialogbox._set_dialog(2, 1, "She's such a special girl, "\
			+ "she gets more than one name...!",
			"res://Scenes/NPC/JackSad.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Globals.set("jack_counter", 2)
		Player._release()
	
	elif ( Globals.jack_counter >= 2 ):
		Dialogbox._set_dialog(2, 1, "You're an adult.\n\n"\
			+ "You must have money somewhere.",
			"res://Scenes/NPC/Jack_Neutral.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._set_dialog(0, 1, "\n		. . .",
			"res://Scenes/Player/Player_Neutral.tex")
			
	Interactor.can_move = true
	Interactor.talking = false
	Interactor._get_pattern(Interactor)
	
	
func _forest_cow():
	if Globals.get("got_daisy"):
		pass
	elif Globals.get("cow_greet"):
		Sound._play_fx('cow')
		_activate_timer( .3 )
		yield( self, "TIMER" )
		Player._release()
	else:
		Dialogbox._set_dialog(2, 1, "\nHow now, [color=maroon]Brown Cow[/color]?",
			"res://Scenes/Player/Player_Grin.tex", false)
		yield( Dialogbox, "next" )
		Dialogbox._close_dialog()
		Sound._play_fx('cow')
		_activate_timer( .3 )
		yield( self, "TIMER" )
		Player._release()
		Globals.set("cow_greet", true)


func _activate_timer( time ):
	if not get_child_count() > 0: #assumes no other children than this timer
		var timer = Timer.new()
		timer.connect("timeout", self, "_timer")
		add_child(timer)
		Delay = timer
	Delay.set_one_shot(true)
	Delay.set_wait_time( time )
	Delay.start()
	
	
func _timer():
	#emit signal when timer runs down
	emit_signal("TIMER")
	
	
	
	
	
	