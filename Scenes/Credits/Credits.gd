extends Node

onready var Anim = get_node("AnimationPlayer")

#onready var track = loader.get_resource("res://Scenes/Title/INTRO See Sixty Funk_Mazedude.ogg")

func _ready():
	Anim.play("roll_credits")
