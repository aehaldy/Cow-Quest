extends Node2D

# Add a blinking "Press Spacebar!" animation

# Set the music track here:
onready var track = load("res://Scenes/Title/INTRO See Sixty Funk_Mazedude.ogg")
onready var Anim = get_node("AnimationPlayer")

#onready var track = loader.get_resource("res://Scenes/Title/INTRO See Sixty Funk_Mazedude.ogg")

func _ready():
	#Make sure Title Screen is visible!
	#Play the bg music:
	Sound.stream(track, false)
	#Processing for input
	set_process_input(true)
	
func _blinker():
	Anim.play("Spacebar_blink")
	
func _input(event):
	if event.is_action_released("ui_accept"):
		Anim.play("FadeTitle")
		#Fade out the music:
		Sound.fadeout()
		#turn off input
		set_process_input(false)
		
func _new_game():
	Anim.play("Opening")
	
func _opening_scene():
		Sound._play_fx("dream_harp")
		#Transition the scene:
		Transition.fade_to("res://Scenes/1Cave/Cave.tscn")
		#var new_track = load("res://Scenes/1Cave/CAVE Zombie Lounge_Mazedude.ogg")
	
		
