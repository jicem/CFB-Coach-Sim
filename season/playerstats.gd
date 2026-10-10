extends Control
var team = Global.team
var database : SQLite
var treerow : TreeItem
@onready var tree = $Tree
@onready var label = %Label

# Called when the node enters the scene tree for the first time.
func _ready():
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
	var array1 : Array = database.select_rows(
		"players1",
		"tid == " + str(team),
		["*"]
	)

	# Define the order in which positions should appear
	var position_order = {
		"QB": 0,
		"WR": 1,
		"RB": 2,
		"TE": 3,
		"OL": 4,
		"DL": 5,
		"LB": 6,
		"CB": 7,
		"S": 8,
		"K": 9
	}

	# Sort the players by position
	array1.sort_custom(func(a, b):
		return position_order[a["position"]] < position_order[b["position"]]
	)

	for row in array1:
		var position = row["position"]

		# Skip offensive linemen and kickers
		if position == "OL":
			continue
		elif position == "K":
			continue

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

		# Add player information
		treerow.set_text(0, row["firstname"])
		treerow.set_text(1, row["lastname"])
		treerow.set_text(2, position)

		query = "SELECT SUM(completions) AS com FROM player_stats WHERE pid = " + str(row["pid"])
		database.query(query)
		for i in database.query_result:
			if i["com"] == null:
				com = 0
			else:
				com = i["com"]

		query = "SELECT SUM(attempts) AS att FROM player_stats WHERE pid = " + str(row["pid"])
		database.query(query)
		for i in database.query_result:
			if i["att"] == null:
				att = 0
			else:
				att = i["att"]

		query = "SELECT SUM(yards) AS ya FROM player_stats WHERE pid = " + str(row["pid"])
		database.query(query)
		for i in database.query_result:
			if i["ya"] == null:
				ya = 0
			else:
				ya = i["ya"]

		query = "SELECT SUM(receptions) AS rec FROM player_stats WHERE pid = " + str(row["pid"])
		database.query(query)
		for i in database.query_result:
			if i["rec"] == null:
				rec = 0
			else:
				rec = i["rec"]

		query = "SELECT SUM(targets) AS tar FROM player_stats WHERE pid = " + str(row["pid"])
		database.query(query)
		for i in database.query_result:
			if i["tar"] == null:
				tar = 0
			else:
				tar = i["tar"]

		query = "SELECT SUM(tackles) AS tac FROM player_stats WHERE pid = " + str(row["pid"])
		database.query(query)
		for i in database.query_result:
			if i["tac"] == null:
				tac = 0
			else:
				tac = i["tac"]

		query = "SELECT SUM(sacks) AS sa FROM player_stats WHERE pid = " + str(row["pid"])
		database.query(query)
		for i in database.query_result:
			if i["sa"] == null:
				sa = 0
			else:
				sa = i["sa"]

		# Add stats to table
		treerow.set_text(3, str(com))
		treerow.set_text(4, str(att))
		treerow.set_text(5, str(ya))
		treerow.set_text(6, str(rec))
		treerow.set_text(7, str(tar))
		treerow.set_text(8, str(tac))
		treerow.set_text(9, str(sa))

func _on_button_pressed():
	get_tree().change_scene_to_file("res://season/review.tscn")
