extends Control
var white : Color = Color.WHITE
var off
var def
@onready var label = %Label
@onready var label2 = %Label2
@onready var label3 = %Label3
@onready var label4 = %Label4
@onready var portrait = $Portrait

# Called when the node enters the scene tree for the first time.
func _ready():
	# Display the name and offensive/defensive schemes the player picked at the start of the game
	if Global.offense == 0: off = "Balanced"
	elif Global.offense == 1: off = "Pass First"
	else: off = "Run First"
	if Global.defense == 0: def = "Balanced"
	elif Global.defense == 1: def = "Stop the Pass"
	else: def = "Stop the Run"
	label2.text = "Name: " + Global.coachname
	label3.text = "Offensive Scheme: " + off
	label4.text = "Defensive Scheme: " + def
	portrait.frame = Global.face

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw():
	draw_circle(Vector2(1014, 136), 120, white)


func _on_button_pressed():
	if Global.state == 1:
		get_tree().change_scene_to_file("res://season/week1.tscn")
	elif Global.state == 2:
		get_tree().change_scene_to_file("res://season/week2.tscn")
	elif Global.state == 3:
		get_tree().change_scene_to_file("res://season/week3.tscn")
	elif Global.state == 4:
		get_tree().change_scene_to_file("res://season/week4.tscn")
	elif Global.state == 5:
		get_tree().change_scene_to_file("res://season/week5.tscn")
	elif Global.state == 6:
		get_tree().change_scene_to_file("res://season/week6.tscn")
	elif Global.state == 7:
		get_tree().change_scene_to_file("res://season/week7.tscn")
