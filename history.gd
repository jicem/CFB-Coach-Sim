extends Control
var team = Global.team
var database : SQLite
var treerow : TreeItem
@onready var tree = $Tree
@onready var label = %Label
@onready var label2 = %Label2
@onready var label3 = %Label3

# Called when the node enters the scene tree for the first time.
func _ready():
	var seasons = 0
	var year = 2024
	# Add column names for tree
	tree.set_column_title(0, "Season")
	tree.set_column_title(1, "Champion")
	tree.set_column_title(2, "Runner-Up")
	# The root node is hidden in the tree
	treerow = tree.create_item()
	treerow.set_text(0, "Hidden")
	treerow.set_text(1, "Hidden")
	treerow.set_text(2, "Hidden")
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	var season_query = "SELECT * FROM seasons"
	database.query(season_query)
	# Update table for each season
	for i in database.query_result:
		# Create variable for tree row
		treerow = tree.create_item()
		# Add data to tree
		treerow.set_text(0, str(year))
		if i["winner"] != null:
			treerow.set_text(1, i["winner"])
		else:
			treerow.set_text(1, "None")
		if i["loser"] != null:
			treerow.set_text(2, i["loser"])
		else:
			treerow.set_text(2, "None")
		# Increase the season count
		seasons += 1
		# Increase the year
		year += 1
	label2.text = "Seasons: " + str(seasons)
	label3.text = "Playtime: %d:%02d" % [Global.playhrs, Global.playmins]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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
	elif Global.state == 8:
		get_tree().change_scene_to_file("res://season/week8.tscn")
	elif Global.state == 9:
		get_tree().change_scene_to_file("res://season/week9.tscn")
	elif Global.state == 10:
		get_tree().change_scene_to_file("res://season/week10.tscn")
	elif Global.state == 11:
		get_tree().change_scene_to_file("res://season/week11.tscn")
	elif Global.state == 12:
		get_tree().change_scene_to_file("res://season/week12.tscn")
	elif Global.state == 13:
		get_tree().change_scene_to_file("res://season/week13.tscn")
	elif(Global.state == 14):
		get_tree().change_scene_to_file("res://season/week14.tscn")
	elif(Global.state == 15):
		get_tree().change_scene_to_file("res://season/week15.tscn")
	elif(Global.state == 16):
		get_tree().change_scene_to_file("res://season/week16.tscn")
	elif(Global.state == 17):
		get_tree().change_scene_to_file("res://season/review.tscn")
