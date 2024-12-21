extends Control
var database: SQLite
@onready var boxes = [$Box, $Box2, $Box3, $Box4, $Box5, $Box6]
@onready var checkedboxes = [$CheckedBox, $CheckedBox2, $CheckedBox3, $CheckedBox4, $CheckedBox5, $CheckedBox6]

func _ready():
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	
	var achievements_query = "SELECT * FROM achievements"
	database.query(achievements_query)
	
	# Iterate through the results and update the UI for each season
	var index = 0
	for achievement in database.query_result:
		if index >= boxes.size() or index >= checkedboxes.size():
			break  # Ensure we don't exceed the number of boxes/checkboxes
		
		if achievement["achieved"] == 0:
			checkedboxes[index].hide()
		else:
			checkedboxes[index].show()
			boxes[index].hide()
		
		index += 1

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
