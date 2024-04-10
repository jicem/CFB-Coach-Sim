extends Control
var season = 2024 + Global.season
var database : SQLite
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.state = 1
	var t = str(Global.team)
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 1, Coach " + Global.coachname + ":"
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://cfb.db"
	database.open_db()
	# Assign random offensive and defensive coordinators to teams outside of the player's
	database.query("UPDATE teams1 SET dcid = abs(RANDOM()) % (80 - 1) + 1, ocid = abs(RANDOM()) % (80 - 1) + 1 WHERE tid <> " + t)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_2_pressed():
	Global.week = 1
	get_tree().change_scene_to_file("res://season/simulation.tscn")


func _on_button_pressed():
	Global.week = 1
	get_tree().change_scene_to_file("res://season/practice.tscn")


func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")
