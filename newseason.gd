extends Control
var season = 2024 + Global.season
var database : SQLite
var treerow : TreeItem
var team = Global.team
@onready var tree = $Tree
@onready var timer = $Timer
@onready var label = %Label

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.gamestarted = true
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
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	# Change label to include the name of the school
	var array1 : Array = database.select_rows("teams", "tid == " + str(team), ["school"])
	for row in array1:
		label.text = row["school"] + " Roster"
	# Select all rows from the table with the specified team ID
	var array2 : Array = database.select_rows("players1", "tid == " + str(team), ["*"])
	for row in array2:
		# Create variable for tree row
		treerow = tree.create_item()
		# Convert jersey number to string
		var textJersey = str(row["jersey"])
		# Convert age to string
		var age = str(season - row["birthyear"])
		# Convert rating to string
		var textRating = str(row["rating"])
		# Add data to tree
		treerow.set_text(0, row["firstname"])
		treerow.set_text(1, row["lastname"])
		treerow.set_text(2, row["position"])
		treerow.set_text(3, textJersey)
		treerow.set_text(4, age)
		treerow.set_text(5, textRating)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	label.text = "Generating schedule..."
	timer.start()
	
func _on_timer_timeout():
	# Create schedule table as dictionary
	var schedule_table = {
		"gid" : {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		"homeTid" : {"data_type":"int"},
		"awayTid" : {"data_type":"int"},
		"conference" : {"data_type":"int"},
		"week" : {"data_type":"int"},
		"homeTeamWon" : {"data_type":"tinyint"}
	}
	database.query("DROP TABLE IF EXISTS schedule")
	database.create_table("schedule", schedule_table)
	# Create an array of numbers between 41 and 80
	var available_ids = []
	for i in range(61, 121):
		available_ids.append(i)

	# Create a loop that inserts a new row into the schedule table 40 times
	for i in range(60):
		# Get the homeTid
		var home_tid = i + 1
		
		# Select a random index from the available_ids array
		var random_index = randi() % available_ids.size()
		
		# Get the awayTid from the selected index
		var away_tid = available_ids[random_index]
		
		# Remove the used value from the array
		available_ids.remove_at(random_index)

		# Insert the row into the schedule table
		var row_data = {
			"homeTid": home_tid,
			"awayTid": away_tid,
			"conference": 0,
			"week": 1,
			"homeTeamWon": -1
		}
		database.insert_row("schedule", row_data)
	get_tree().change_scene_to_file("res://season/week1.tscn")
