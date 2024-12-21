extends Control
var white : Color = Color.WHITE
var team = Global.team
var off
var def
var database : SQLite
var treerow : TreeItem
@onready var tree = $Tree
@onready var label = %Label
@onready var label2 = %Label2
@onready var label3 = %Label3
@onready var label4 = %Label4
@onready var label6 = %Label6
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
	if Global.admood >= 5: label6.text = "AD Mood: 😀"
	elif Global.admood == 4: label6.text = "AD Mood: 🙂"
	elif Global.admood == 3: label6.text = "AD Mood: 😐"
	elif Global.admood == 2: label6.text = "AD Mood: 🙁"
	elif Global.admood <= 1: label6.text = "AD Mood: 😡"
	# Add column names for tree
	tree.set_column_title(0, "First Name")
	tree.set_column_title(1, "Last Name")
	tree.set_column_title(2, "Position")
	tree.set_column_title(3, "Completions")
	tree.set_column_title(4, "Attempts")
	tree.set_column_title(5, "Yards")
	tree.set_column_title(6, "Receptions")
	tree.set_column_title(7, "Targets")
	tree.set_column_title(8, "Tackles")
	tree.set_column_title(9, "Sacks")
	# The root node is hidden in the tree
	treerow = tree.create_item()
	for i in range(10):
		treerow.set_text(i, "Hidden")
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	# Select all rows from the table with the current team ID
	var array1 : Array = database.select_rows("players", "tid == " + str(team), ["*"])
	for row in array1:
		var position = row["position"]
		if(position == "OL"): continue
		elif(position == "K"): continue
		else:
			var query
			var com
			var att
			var ya
			var rec
			var tar
			var tac
			var sa
			# Create variable for tree row
			treerow = tree.create_item()
			# Add data to tree
			treerow.set_text(0, row["firstname"])
			treerow.set_text(1, row["lastname"])
			treerow.set_text(2, position)
			query = "SELECT SUM(completions) AS com FROM player_stats WHERE pid = " + str(row["pid"])
			database.query(query)
			for i in database.query_result:
				if i["com"] == null: com = 0
				else: com = i["com"]
			query = "SELECT SUM(attempts) AS att FROM player_stats WHERE pid = " + str(row["pid"])
			database.query(query)
			for i in database.query_result:
				if i["att"] == null: att = 0
				else: att = i["att"]
			query = "SELECT SUM(yards) AS ya FROM player_stats WHERE pid = " + str(row["pid"])
			database.query(query)
			for i in database.query_result:
				if i["ya"] == null: ya = 0
				else: ya = i["ya"]
			query = "SELECT SUM(receptions) AS rec FROM player_stats WHERE pid = " + str(row["pid"])
			database.query(query)
			for i in database.query_result:
				if i["rec"] == null: rec = 0
				else: rec = i["rec"]
			query = "SELECT SUM(targets) AS tar FROM player_stats WHERE pid = " + str(row["pid"])
			database.query(query)
			for i in database.query_result:
				if i["tar"] == null: tar = 0
				else: tar = i["tar"]
			query = "SELECT SUM(tackles) AS tac FROM player_stats WHERE pid = " + str(row["pid"])
			database.query(query)
			for i in database.query_result:
				if i["tac"] == null: tac = 0
				else: tac = i["tac"]
			query = "SELECT SUM(sacks) AS sa FROM player_stats WHERE pid = " + str(row["pid"])
			database.query(query)
			for i in database.query_result:
				if i["sa"] == null: sa = 0
				else: sa = i["sa"]
			# Add to table
			treerow.set_text(3, str(com))
			treerow.set_text(4, str(att))
			treerow.set_text(5, str(ya))
			treerow.set_text(6, str(rec))
			treerow.set_text(7, str(tar))
			treerow.set_text(8, str(tac))
			treerow.set_text(9, str(sa))

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
