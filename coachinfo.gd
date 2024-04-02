extends Control
@onready var option1 = $OptionButton
@onready var option2 = $OptionButton2
@onready var input = $LineEdit
@onready var portrait = $Portrait

# Called when the node enters the scene tree for the first time.
func _ready():
	option1.add_item("Balanced")
	option1.add_item("Pass First")
	option1.add_item("Run First")
	option2.add_item("Balanced")
	option2.add_item("Stop the Pass")
	option2.add_item("Stop the Run")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_option_button_item_selected(index):
	if index == 1: Global.offense = 1
	elif index == 2: Global.offense = 2
	else: pass

func _on_option_button_2_item_selected(index):
	if index == 1: Global.defense = 1
	elif index == 2: Global.defense = 2
	else: pass

func _on_button_pressed():
	Global.coachname = input.text
	Global.face = portrait.frame
	get_tree().change_scene_to_file("res://oclist.tscn")


func _on_prev_button_pressed():
	# If the previous button is pressed, the previous face will be displayed
	if portrait.frame == 0: portrait.frame = 20
	else: portrait.frame -= 1


func _on_next_button_pressed():
	# If the next button is pressed, the next face will be displayed
	if portrait.frame == 20: portrait.frame = 0
	else: portrait.frame += 1
