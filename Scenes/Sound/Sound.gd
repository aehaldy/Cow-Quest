extends Node

#Global script for managing sound and music

onready var Sampler = get_node("SamplePlayer")
onready var Streamer = get_node("StreamPlayer")
onready var Effect = get_node("AnimationPlayer")
var loop = true #default is to loop tracks
var track

func _ready():
	pass

func stream(music, loopbool=true):
	#Make sure the Streamer's volume is normal
	Streamer.set_volume_db(0)
	#Stream the track
	Streamer.set_stream(music)
	Streamer.play()
	print("Streaming: ", music, " on: ", Streamer, " at buffer: ", Streamer.get_buffering_msec())
	#Set loop preferance; 'true' is default
	if loopbool == false:
		Streamer.set_loop(false)
	
func fadeout(): #Fadeout seems to permanently stop the player on scene transitions
	#Used for fadeout, stops the Streamer
	Effect.play("fadeout")
	
func crossfade(new_track, loopbool):
	#Store the track:
	track = new_track
	#Store the loop preferance: 
	loop = loopbool
	#Run Crossfade animation which calls other functions:
	Effect.play("crossfade")
	
func streamstop():
	#Stop the current track
	Streamer.stop()
	
func new_stream():
	#Set the stream to resource stored in "track" var
	Streamer.set_stream(track)
	Streamer.play()
	#Set loop based on "loop" boolean 
	Streamer.set_loop(loop)
	
func _play_fx( sfx ):
	#var sound = load( sfx )
	Sampler.play( sfx )
	
	#Other ideas for functions/animations:
		#Play at lower volume (for indoor scenes)
		#Slower fadeout, no cross 