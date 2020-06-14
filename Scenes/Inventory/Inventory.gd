extends CanvasLayer

#=======================================================
#
#		* Simple Inventory Display System *
#
#	Display icons for collected items.
#	Extend the inventory window as items added.
#	Toggle on- and off-screen.
#	Becomes available with first item.
#-------------------------------------------------------

onready var Gui = get_node("TextureFrame")
onready var Panelcontainer = Gui.get_node("PanelContainer")
onready var Sprite0 = Panelcontainer.get_node("Sprite0")
onready var icon_sheet = load("res://Scenes/Inventory/Inventory.tex")
var hidden = true
var inventory_toggle = false
var pos #for GUI
var frames #for Sprite

#-------------------------------------------------------

func _ready():
	#Create the Inventory for the game:
	if not Globals.has("inventory"):
		Globals.set("inventory", {
			'Pouch':{ 'qty':0, 'frame':0 },
			'Bean Pouch':{ 'qty':0, 'frame':1 },
			'Sparkle Beans':{ 'qty':0, 'frame':2 },
			'Bottle':{ 'qty':0, 'frame':3 },
			'SuperGro':{ 'qty': 0, 'frame': 4 }
			})
	
	if hidden == false:
		_update_inventory()
	else:
		Gui.hide()
		set_process_input(false)
	#set default inventory position
	#	NOTE: Must be sibling of Grid!
	var screen_w = get_viewport().get_rect().size.x
	pos = Vector2(screen_w-140,96)
	if inventory_toggle == true:
		#set pos to toggled offscreen
		Gui.set_pos(pos+Vector2(97,0))
	else:
		#set pos at default pos
		Gui.set_pos(pos)
	
	
func _update_inventory():
	#Get inventory SIZE, iterate values from dict
	var i_dict = Globals.inventory
	#list the values
	frames = []
	var i
	for i in i_dict.keys():
		if i_dict[i]['qty']>0:
			frames.append(i_dict[i]['frame'])
			
	#If nothing in inventory, hide it.
	if frames == []:
		Gui.hide()
		set_process_input(false)
		inventory_toggle = false
	_update_gui()
	
	
func _update_gui():
	var sprites = Panelcontainer.get_children()
	#eliminate extra sprites, if exist
	if sprites.size() > frames.size():
		var diff = sprites.size() - frames.size()
		var d
		for d in range(diff):
			var extra = sprites.back()
			Panelcontainer.remove_child(extra)
			sprites.pop_back()
			
	#set the sprites to the desired number of sprites
	#Set sprite icons by frame number
	var icon
	for icon in range(frames.size()):
		#add sprites as needed
		if sprites.size() == icon:
			var new_sprite = Sprite.new()
			Panelcontainer.add_child(new_sprite)
			#position sprite
			new_sprite.set_centered(false)
			new_sprite.set_pos( Vector2( 16,16+(64*icon) ))
			#load sprite sheet
			new_sprite.set_texture(icon_sheet)
			new_sprite.set_hframes(3)
			new_sprite.set_vframes(2)
			
		#update array of sprites
		sprites = Panelcontainer.get_children()
		var this_sprite = sprites[icon] 
		#display the icon
		this_sprite.set_frame(frames[icon]) 
	
	#stretch panelcontainer down to include all sprites
	var desired_height
	var panel_end = Panelcontainer.get_end()
	if sprites.size() > 1:
		Panelcontainer.set_end(Vector2(panel_end.x,((sprites.size() * 64) + 16)))
	else:
		Panelcontainer.set_end(Vector2(panel_end.x, 75))
	
	#update the gui (built-in function)
	Panelcontainer.update()
	Gui.show()
	set_process_input(true)
	
	
func _input(event):
	if (event.is_action_pressed( "ui_toggle" ) 
		&& !event.is_echo() ):
		_tween_toggle()
		get_tree().set_input_as_handled()
	else:
		pass
	
	
func _tween_toggle():
	var Tweener = get_node("TextureFrame/Tween")
	var to_pos 
	if inventory_toggle == false:
		#toggled offscreen
		to_pos = pos+Vector2(97,0)
		Tweener.interpolate_property( Gui, "rect/pos", Gui.get_pos(), 
			to_pos, .25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT )
		Tweener.start()
		inventory_toggle = true
	else:
		#move to default pos 
		to_pos = pos
		Tweener.interpolate_property( Gui, "rect/pos", Gui.get_pos(), 
			to_pos, .25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT )
		Tweener.start()
		inventory_toggle = false
		
		
	

