extends PanelContainer
#==========================================================
#
#                     INSTRUCTIONS
#
#----------------------------------------------------------
#	1. Set Panel (in Inspector) Custom Styles:
#		check 'Panel' box, set to 'New StyleBoxEmpty'
#		This renders a graphically empty panel to which we add StyleBoxes
#
#	2. Load StyleBox textures as resources
#
#	3. NOTE: The PanelContainer controls the script; RichTextLabel and Label
#		must be siblings; TextureFrame and VButtonArray are children... (?)
#
#	4. The _set_dialog() function receives arguments from outside node:
#		* Where and how large the dialog box
#		* What StyleBox skin to use (theme, shadow, or none)
#		* If there is a picture, and which one to draw
#		* What dialog text to display
#		* Single string (to be parsed) of choices
#
#
#==================================================================

#======#	VARIABLES	#=======#
signal next
var dialog_end #bool to indicate if the dialog is over
var choice_buttons #String of choices (or null)
var choice_count #getting the number of choices
var selection #For passing choice selection back to Parser
var style 
var text = ""
onready var Textbx = get_node("../RichTextLabel")
onready var Portrait = get_node("../TextureFrame")
onready var Choices = get_node("../VButtonArray")
var face
var picsize = Vector2(0,0) 

#width of the dialog box default is screen width
onready var w = get_viewport().get_rect().size.x
#height of the dialog box depends on text content
var h
#for calculations:
onready var screen_h = get_viewport().get_rect().size.y
	
# Give some padding to the RichTextLabel, depending on
# the Stylebox margins
var padding_x = 20 #pixels
var padding_y = 20 #pixels

#Dynamically control the minimum window size
#Set a default value here
#THIS IS A 'y' variable ONLY!!!
var minsize = padding_y + 96


#No way to dynamically size with buttons because of draw time
#So figure out the pixel height needed per button:
var button_h = 39

#The label...
onready var label = get_node("../Label")


#Need Player node to release movement
#NOTE: The parent CanvasLayer must be sibling to Grid!
onready var Player = get_node("../../Grid/Player")

#==============================================================

func _ready():
	pass

func _set_dialog( pos, skin, dialog, pic=null, end=true, choices=null ):
	#Some variables for later use:
	dialog_end = end
	choice_buttons = choices
	var window_origin_y
	
	#========================================================
	#	Prepare to size the window depending on the picture 
	#========================================================
	if pic != null:
		face = load( pic )
		picsize = face.get_size()
		if picsize.y+padding_y > minsize:
			minsize = picsize.y+(padding_y*2)
			padding_x = padding_x*2
	else:
		face = null
		picsize = Vector2(0,0)
		
	#Preparing the label size to measure line-count:
	var label_padding = (padding_x)+picsize.x+10
	var label_edge = w-label_padding
	label.set_begin( Vector2(label_padding,0) )
	label.set_size( Vector2(label_edge,minsize) )
	
	#========================================================
	#	Calculate dialog window size based on line count
	#========================================================
	text = dialog
	if text != null:
		#Use Label to measure line-count
		h = _size_calculator( text ) 
	else:
		h = 0
	var text_h = h
	
	#========================================================
	#****	Add choices, buttons to height	*************
	#========================================================
	if choice_buttons != null:
		#Create the Vbuttons to hold the choices
		var choice_list = choice_buttons.split(";")
		choice_count = choice_list.size()
		for i in choice_list:
			Choices.add_button(i)
		var choice_h = Choices.get_rect().size.y
		#Add window height based on no. of choices:
		h += (choice_count * button_h) #+ padding_y 
	else:
		h = text_h
	

	
	#FINALIZE WINDOW HEIGHT
	if h < minsize:
		h = minsize
	#=======================================================
	#	Customize the PanelContainer position (pos)
	#=======================================================
	if pos == 0: #Dialog at bottom of screen
		window_origin_y = screen_h - h
		self.set_begin( Vector2(0,window_origin_y ) )
		self.set_end( Vector2(w,screen_h) )
	elif pos == 1: #Dialog centered on screen
		window_origin_y  = (screen_h - h)/2
		self.set_begin( Vector2(0,window_origin_y ) )
		self.set_end( Vector2(w,window_origin_y+h) )
	elif pos == 2: #Dialog at top of screen
		self.set_begin( Vector2(0,0) )
		self.set_end( Vector2(w,h) )
	
	#=================================================
	# Customize TextureFrame position
	#=================================================
	if face != null:
		Portrait.set_begin(self.get_begin()+Vector2(padding_x/2,padding_y))
	
	#=================================================
	# Customize RichTextLabel position
	#=================================================
	#Match text height, not TextureFrame height
	Textbx.set_pos( self.get_begin() + Vector2(padding_x+picsize.x,padding_y) )
	var textend_x = self.get_end().x - (padding_x+picsize.x) - 10 #Extra padding for looks
	#var textend_y = self.get_begin().y + text_h 
	Textbx.set_size( Vector2(textend_x, text_h ) )
	
	#=================================================
	# Customize VButtonArray position
	#=================================================
	if choice_buttons != null:
		var intropos_x = Textbx.get_begin().x
		var intropos_y = Textbx.get_end().y
		Choices.set_pos( Vector2(intropos_x,intropos_y) ) #Position based on label
		#Choices.set_size( Vector2(textbx.get_size().x-3, textbx.get_size().y-20) )
		
	#================================================
	#	Customize the window skin
	#================================================
	if skin == 0:
		style = null #no stylebox
	elif skin == 1:
		style = load( "res://Scenes/Dialogbox/cq_stylebox.tres" ) 
	elif skin == 2:
		style = load( "res://Scenes/Dialogbox/dim_stylebox.tres" )
	
	#=================================================
	# Get ready to handle Player input
	#=================================================
	set_process_input(true)
	
	#=================================================
	# Redraw the controls
	#=================================================
	self.show()
	Textbx.show()
	Portrait.show()
	Choices.show()
	update()
	
	
	#========================================================
	#	Calculate dialog window size based on character count
	#========================================================
func _size_calculator( text ):
	#	Parse the text for character count & newlines. 
	#	Label node has better text wrapping and size
	#	calculating abilities than RichTextLabel.
	#	That's why we use it here to calculate the
	#	size of the dialog window. But we use RTL
	#	to display the text because it can parse BBcode
	
	#Strip text of bbcode to better measure it's length
	var text_array = text.split(']')
	var temp_string
	var final_array = []
	var new_text = ""
	var i #iterating for-loop
	for i in text_array:
		var temp_array = []
		#each index to string, parse bbcode
		temp_string = i
		temp_array = temp_string.split('[')
		final_array.append(temp_array[0])
	for i in final_array:
		new_text += i
		
	label.set_text(new_text)
	var lin_h = label.get_line_height()
	var lines = label.get_line_count()
	var height = lin_h * lines
	var new_h = height + (padding_y*2)
	return new_h
	
		
func _draw():
	if style != null:
		draw_style_box(style,(Rect2(0,0,w,h)))
	Portrait.set_texture( face )
	if text != null:
		Textbx.set_bbcode(text)

		
func _input(event):
	if choice_buttons == null:
		if event.is_action_pressed( "ui_accept" ) && !event.is_echo():
			get_tree().set_input_as_handled()
			if dialog_end == false:
				emit_signal("next")
			else:
				#	The dialog is over, so close
				#	the window and release the Player
				_close_dialog()
				Player._release()
		else:
			pass
				
				
	else:
		var choice
		if ( event.is_action( "ui_down" ) && event.is_pressed() && !event.is_echo() ):
			choice = Choices.get_selected()
			if (choice == choice_count-1):
				Choices.set_selected(0)
			else:
				Choices.set_selected( choice+1 )
		elif ( event.is_action( "ui_up" ) && event.is_pressed() && !event.is_echo() ):
			choice = Choices.get_selected()
			if ( choice == 0 ):
				Choices.set_selected( choice_count-1 )
			else:
				Choices.set_selected( choice-1 )
		elif ( event.is_action( "ui_accept" ) && event.is_pressed() && !event.is_echo() ):
			get_tree().set_input_as_handled()
			selection = Choices.get_selected()
			Choices.clear()
			if dialog_end == false:
				emit_signal("next")
			else:
				_close_dialog()
				Player._release()
				


	
func _close_dialog():
	#####################################################
	#	TBD: Animate dialog window opening and closing	
	#####################################################
	set_process_input(false)
	Choices.hide()
	Textbx.hide()
	Portrait.hide()
	self.hide()
		

