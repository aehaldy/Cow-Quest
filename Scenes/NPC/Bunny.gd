extends Area2D

onready var Anibun = get_node("../AnimationPlayer")
onready var Player = get_node("../../Player")
onready var Dialogbox = get_node("../../../Dialogbox/PanelContainer")
onready var Bunny = get_node("../Sprite")
onready var Tweener = get_node("../Tween")
onready var eta = get_node("../Timer")
var tweencnt = 0

func _ready():
	eta.connect("timeout",self, "_bun_return1")
	
	
func _on_Area2D_body_enter( body ):
	if body.get_name() == "Player" && Bunny.is_visible():
		if not Globals.get("saw_bunny"):
			_first_sighting()
			Globals.set("saw_bunny", true)
		else:
			_bun_run()
	elif not Bunny.is_visible():
		eta.stop()
	else:
		pass
	
	
func _on_Area2D_body_exit( body ):
	if body.get_name() == "Player":
		eta.set_one_shot(true)
		eta.set_wait_time(45)
		eta.start()
	else:
		pass
	
	
func _bun_run():
	var bunpos = Bunny.get_pos()
	Anibun.play("flee")
	Tweener.interpolate_property( Bunny, 'transform/pos', bunpos, Vector2(128,0), 
		.6, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, .5 )
	Tweener.start()
	
	
func _bun_return1():
	Anibun.play("return")
	Tweener.interpolate_property( Bunny, 'transform/pos', Vector2(128,0), Vector2(64,0), 
		.6, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	Tweener.start()
	
	
func _bun_return2():
	Tweener.interpolate_property( Bunny, 'transform/pos', Vector2(64,0), Vector2(0,0),
		.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	Tweener.start()
	
	
func _idle_bun():
	Anibun.play("idle")
	
	
func _first_sighting():
	set_process(true)
	

func _process(delta):
	#	Wait for Player to fully move onto current grid tile.
	if Player.is_moving == false:
		_complete_event()
		

func _complete_event():
	Player.can_move = false
	Player.set_fixed_process(false)
	Player.Aniplayer.stop()
	set_process(false)
	Dialogbox._set_dialog(0, 1, "\nI could turn that rabbit into a " \
		+"[color=maroon]brown cow[/color]!", 
		"res://Scenes/Player/Player_Grin.tex", false)
	yield( Dialogbox, "next" ) 
	
	_bun_run()
	
	Dialogbox._set_dialog(0, 1, "\nIf I knew the right spell...", 
		"res://Scenes/Player/Player_Neutral.tex")