extends Camera2D

#On Initalization, set the camera limits to the current map size.
#	NOTE -- vocabulary used is currently consistent with this game's 
#	use of a grid/tilemap-based movement - i.e., the "Grid" node.
#	SEE ALSO: Grid scene & script.
####################################################################

#Set the tile size for your game:
var tile_size = Vector2(64,64) 
#Create a variable to store the map's dimensions:
var map_size

var pan_to 
onready var Tweener = get_node("../Tween")
signal CAM_PANNED


func _ready():
	# not sure if need:
	Tweener.connect("tween_complete", self, "_tween_done")
	
	#Get the dimensions already recorded by Grid
	#	NOTE!! - This camera's parent, Player,  
	#	must always be direct child of Grid!!
	#	ALSO - because GRID is in units of 64 pixels right now
	#	(SEE tile_size) we must multiply the grid by 64:
	yield(get_tree(), 'idle_frame')
	map_size = get_parent().get_parent().grid_size * tile_size
	
	#Set (x,y) (rectangle size from origin (0,0)) limits accordingly...
	#	NOTE: The origin (0.0) limit must be set in the editor.
	set_limit( 2, map_size.x )
	set_limit( 3, map_size.y )

#	These limits ^ are used to keep the camera within bounds 
#	of the visible map; ALSO the Player script uses the same
#	information to keep the player from walking off the map.
#	SEE ALSO: player.gd script.

func _pan( coords, duration ):
	#Pan the camera using Tween to specific coordinates
	#coors are number of tiles in whichever directions
	#ex: if coords = 2, -8, move cam two tiles right and eight tiles up
	#	***Not sure if this will exceed limits. (?)
	pan_to = coords*tile_size
	Tweener.interpolate_property( self, 'transform/pos', get_pos(), pan_to, 
		duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT )
	Tweener.start()
	
	
func _pan_back( duration ):
	#var player_pos = get_parent().get_pos()
	#var depan = pan_to*Vector2(-1,-1)
	#Return a panned camera to the player
	Tweener.interpolate_property( self, 'transform/pos', get_pos(), Vector2(0,0), 
		duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT )
	Tweener.start()
	
	
func _tween_done(obj, key):
	emit_signal("CAM_PANNED")

	
