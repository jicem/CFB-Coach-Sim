extends Control
var season = 2024 + Global.season
var team = Global.team
var database : SQLite
var treerow : TreeItem
var treerow1 : TreeItem
@onready var tree = $Tree
@onready var tree2 = $Tree2

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add column names for tree
	tree.set_column_title(0, "First Name")
	tree.set_column_title(1, "Last Name")
	tree.set_column_title(2, "Position")
	tree.set_column_title(3, "Jersey Number")
	tree.set_column_title(4, "Age")
	tree.set_column_title(5, "Rating")
	# The root node is hidden in the tree
	treerow = tree.create_item()
	treerow.set_text(0, "Hidden")
	treerow.set_text(1, "Hidden")
	treerow.set_text(2, "Hidden")
	treerow.set_text(3, "Hidden")
	treerow.set_text(4, "Hidden")
	treerow.set_text(5, "Hidden")
	# Add column names for tree
	tree2.set_column_title(0, "First Name")
	tree2.set_column_title(1, "Last Name")
	tree2.set_column_title(2, "Position")
	tree2.set_column_title(3, "Jersey Number")
	tree2.set_column_title(4, "Age")
	tree2.set_column_title(5, "Rating")
	# The root node is hidden in the tree
	treerow1 = tree2.create_item()
	treerow1.set_text(0, "Hidden")
	treerow1.set_text(1, "Hidden")
	treerow1.set_text(2, "Hidden")
	treerow1.set_text(3, "Hidden")
	treerow1.set_text(4, "Hidden")
	treerow1.set_text(5, "Hidden")
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	# Select all rows from the table with the specified team ID
	var array1 : Array = database.select_rows("players1", "birthyear == " + str(season - 22), ["*"])
	for row in array1:
		if row["tid"] == team:
			var age = season - row["birthyear"]
			var pos = row["position"]
			if age == 22:
				if pos == "QB": Global.qbsneeded += 1
				elif pos == "RB": Global.rbsneeded += 1
				elif pos == "WR": Global.wrsneeded += 1
				elif pos == "TE": Global.tesneeded += 1
				elif pos == "OL": Global.olsneeded += 1
				elif pos == "DL": Global.dlsneeded += 1
				elif pos == "LB": Global.lbsneeded += 1
				elif pos == "CB": Global.cbsneeded += 1
				elif pos == "S": Global.sneeded += 1
				elif pos == "K": Global.kneeded += 1
				# Create variable for tree row
				treerow = tree.create_item()
				# Convert jersey number to string
				var textJersey = str(row["jersey"])
				# Convert rating to string
				var textRating = str(row["rating"])
				# Add data to tree
				treerow.set_text(0, row["firstname"])
				treerow.set_text(1, row["lastname"])
				treerow.set_text(2, pos)
				treerow.set_text(3, textJersey)
				treerow.set_text(4, str(age))
				treerow.set_text(5, textRating)
		database.delete_rows("players1", "pid = " + str(row["pid"]))
		
	# Create transfers table
	var player_table = {
		"pid" : {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		"firstname" : {"data_type":"text"},
		"lastname" : {"data_type":"text"},
		"tid" : {"data_type":"int"},
		"birthyear" : {"data_type":"int"},
		"position" : {"data_type":"text"},
		"jersey" : {"data_type":"int"},
		"state" : {"data_type":"text"},
		"rating" : {"data_type":"int"},
		"nil" : {"data_type":"float"}
	}
	database.query("DROP TABLE IF EXISTS transfers")
	database.create_table("transfers", player_table)
	database.query("SELECT * FROM players1")
	for i in database.query_result:
		var pos = i["position"]
		var rating = i["rating"]
		var nil_value = 0
		if rating > 40:
			nil_value = (float(rating) - 20) / 60 * 1000000
		# Compare states
		var array2 : Array = database.select_rows("teams", "tid == " + str(team), ["state"])
		for row in array2:
			if i["state"] == row["state"]:
				nil_value = nil_value / 2
		if randi() % 10 == 5:
			var data = {
				"firstname" : i["firstname"],
				"lastname" : i["lastname"],
				"tid" : i["tid"],
				"birthyear" : i["birthyear"],
				"position" : i["position"],
				"jersey" : i["jersey"],
				"state" : i["state"],
				"rating" : rating,
				"nil" : nil_value
			}
			database.insert_row("transfers", data)
			if i["tid"] == team:
				if pos == "QB": Global.qbsneeded += 1
				elif pos == "RB": Global.rbsneeded += 1
				elif pos == "WR": Global.wrsneeded += 1
				elif pos == "TE": Global.tesneeded += 1
				elif pos == "OL": Global.olsneeded += 1
				elif pos == "DL": Global.dlsneeded += 1
				elif pos == "LB": Global.lbsneeded += 1
				elif pos == "CB": Global.cbsneeded += 1
				elif pos == "S": Global.sneeded += 1
				elif pos == "K": Global.kneeded += 1
				# Create variable for tree row
				treerow1 = tree2.create_item()
				# Convert jersey number to string
				var textJersey = str(i["jersey"])
				# Convert age to string
				var age = str(season - i["birthyear"])
				# Convert rating to string
				var textRating = str(i["rating"])
				# Add data to tree
				treerow1.set_text(0, i["firstname"])
				treerow1.set_text(1, i["lastname"])
				treerow1.set_text(2, pos)
				treerow1.set_text(3, textJersey)
				treerow1.set_text(4, str(age))
				treerow1.set_text(5, textRating)
			database.delete_rows("players1", "pid = " + str(i["pid"]))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	# Update school budgets
	var array : Array = database.select_rows("teams1", "tid == " + str(team), ['*'])
	for row in array:
		database.update_rows("teams1", "tid = " + str(team), {"budget": row["prestige"] * 80000})
	# Create recruits table
	var player_table = {
		"pid" : {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		"firstname" : {"data_type":"text"},
		"lastname" : {"data_type":"text"},
		"birthyear" : {"data_type":"int"},
		"position" : {"data_type":"text"},
		"jersey" : {"data_type":"int"},
		"state" : {"data_type":"text"},
		"rating" : {"data_type":"int"},
		"nil" : {"data_type":"float"}
	}
	database.query("DROP TABLE IF EXISTS recruits")
	database.create_table("recruits", player_table)
	var positiions = ["QB", "RB", "RB", "WR", "WR", "TE", "OL", "OL", "OL", "OL", "OL", "DL", "DL", "DL", "DL", "LB", "LB", "LB", "CB", "CB", "S", "S", "K"]
	for p in positiions:
		for i in range(40):
			var first
			var last
			var birth = season - 18
			var jersey = randi() % 100
			var state
			var rating = randi() % 59 + 29
			database.query("SELECT firstname FROM players1 ORDER BY RANDOM() LIMIT 1")
			for r in database.query_result:
				first = r["firstname"]
			database.query("SELECT lastname FROM players1 ORDER BY RANDOM() LIMIT 1")
			for r in database.query_result:
				last = r["lastname"]
			var nil_value = 0
			if rating > 40:
				nil_value = (float(rating) - 30) / 60 * 1000000
			database.query("SELECT abbrev FROM states ORDER BY RANDOM() LIMIT 1")
			for r in database.query_result:
				state = r["abbrev"]
			var array3 : Array = database.select_rows("teams", "tid == " + str(team), ["state"])
			for row in array3:
				if state == row["state"]:
					nil_value = nil_value / 2
			# Adjust nil_value by a random factor between 0.6 and 1.2
			nil_value *= randf_range(0.6, 1.2)
			var data = {
				"firstname" : first,
				"lastname" : last,
				"birthyear" : birth,
				"position" : p,
				"jersey" : jersey,
				"state" : state,
				"rating" : rating,
				"nil" : nil_value
			}
			database.insert_row("recruits", data)
			
	get_tree().change_scene_to_file("res://recruiting/hs.tscn")
