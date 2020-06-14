extends StaticBody2D

#=====================================================
#	Base Script of Non-Character Object Handling
#=====================================================

onready var objname = self.get_name()


func _ready():
	#Declare some global arrays --instead of using Groups
	if not Globals.has("static_frame"):
		Globals.set("static_frame",{})
	if not Globals.has("hidden_group"):
		Globals.set("hidden_group",[])
	if Globals.hidden_group.has( objname ):
		get_node("Sprite").hide()
	elif Globals.static_frame.has( objname ):
		var frame = Globals.static_frame[ objname ]
		get_node("Sprite").set_frame(frame)
	
#Collect function should be part of inventory; break apart:	
func _collect_item( item, amt=1 ):
	#Lookup 'item' in the Global.inventory[dictionary] 
	var it = Globals.inventory[item]
	#Play SE 
	#Sound._play_fx("item")
	#add item to Global Inventory
	it['qty'] += amt
	#Add to Inactive Group and hide the sprite
	if Globals.hidden_group.has( objname ):
		get_node("Sprite").hide()
	elif Globals.static_frame.has( objname ):
		var frame = Globals.static_frame[objname]
		get_node("Sprite").set_frame(frame)
	Inventory._update_inventory()


func _remove_item( item, amt=1 ):
	#Lookup 'item' in the Global.inventory[dictionary] 
	var it = Globals.inventory[item]
	#Remove item from Global Inventory
	if it['qty'] >= amt:
		it['qty'] -= amt
	elif it['qty'] < amt and it['qty'] > 0:
		it['qty']  = 0
	Inventory._update_inventory()
	
		
		
