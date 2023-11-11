extends Control

@onready var name_label = $ColorRect/NameLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_player_data(player_name):
	name_label.text = str(player_name)
	
