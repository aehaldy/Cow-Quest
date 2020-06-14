extends TileMap


#In new game, specify the size of grid tiles for your game:
var tile_size = Vector2(64,64) 

#signal READY 
#needed to communicate with NPC nodes that must wait until parent is ready

#For placing things on "tiles"
var half_tile_size = tile_size / 2
var grid = []
#modify Grid extensibly to adjust to current map, divide by tile size
var grid_size = Vector2()

#These constants are used to hold places in the grid
const PLAYER = 0 #The player
const OBSTACLE = 1 #static barriers with no dynamism
const INTERACTOR = 2 #NPCs and objects that can interact

onready var Player = get_node("Player")

#==========================================================================

func _ready():
	#Check if Tilemap or Image map, and calculate size of grid accordingly
	grid_size = get_grid_size()
	#not sure the purpose of this yet:
	for x in range(grid_size.x):
		grid.append([])
		for y in range(grid_size.y):
			grid[x].append(null)
			
	#Control player movement
	var start_pos = update_child_pos(Player)
	
	#var obstacles = []
	#CREATING OBSTACLES 
	#experiment with checking physics of static children point intersection...
	#Do this in fixed process delta?? --cant just check for polygon??
	#var collisions = get_nodeget_world().get_direct_space_state()
	#print(collisions)
	#var col = collisions.intersect_point((grid.x-half_tile, grid.y-half_tile), 10, [], 2147483647, 1)
	
	#Storing information in Grid Array... (?!?!?)
	#for pos in obstacles:
	#	grid[pos.x][pos.y] = OBSTACLE
	
	
	
func get_grid_size():
	
	if (has_node("Map")):
		#Tilemap scene node MUST be called "Map" & have full area "Ground" tilemap child 
		var map_size = Vector2(get_node("Map/Ground").get_used_rect().size) 
		return map_size
	elif (has_node("Floor")): 
		#Image-based 'maps' must have "Floor" sprite covering full map area
		var sizetest = Vector2(get_node("Floor").get_texture().get_size()/tile_size)
		return Vector2(get_node("Floor").get_texture().get_size()/tile_size) 
	else:
		return Vector2(960,640) #set to game's resolution
	
	
func is_cell_vacant(pos=Vector2(), dir=Vector2()): 
	var grid_pos = world_to_map(pos) + dir
	if grid_pos.x < grid_size.x and grid_pos.x >= 0:
		if grid_pos.y < grid_size.y and grid_pos.y >= 0:
			return grid[grid_pos.x][grid_pos.y] #== null else false -> return Const instead of Bool
		else:
			return 1
	else:
		return 1
	

#func get_target_cell_value(child_node): 
#	var pos = child_node.get_pos()
#	var grid_pos = world_to_map(pos) + child_node.dir
#	return grid[grid_pos.x][grid_pos.y] 
	
	
#func navigate_grid(child_node, target=Vector2()):
#	pass
	
	
func update_child_pos(child_node):
	#Move child to a new position in grid array
	#Returns the new target world position of the child
	var grid_pos = world_to_map(child_node.get_pos())
	#Occupying child is leaving the space, so we set it to empty:
	grid[grid_pos.x][grid_pos.y] = null
	#Next, calculate the new position
	var new_grid_pos = grid_pos + child_node.dir
	grid[new_grid_pos.x][new_grid_pos.y] = child_node.type
	var target_pos = map_to_world(new_grid_pos) + half_tile_size
	return target_pos
	
	
func correct_grid(child_node, old_pos):
	#To correct the mover's pos if it has moved via animation (instead of grid)
	#find old pos and set to null, then set new pos to occupied
	var grid_pos = world_to_map(child_node.get_pos())
	var old_grid = world_to_map(old_pos)
	grid[grid_pos.x][grid_pos.y] = child_node.type
	grid[old_grid.x][old_grid.y] = null
	
	