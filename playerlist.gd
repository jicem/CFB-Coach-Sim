extends Control
var database : SQLite
var treerow : TreeItem
var team = Global.team
@onready var tree = $Tree
@onready var timer = $Timer
@onready var label = %Label

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add column names for tree
	tree.set_column_title(0, "First Name")
	tree.set_column_title(1, "Last Name")
	tree.set_column_title(2, "Position")
	tree.set_column_title(3, "Jersey Number")
	tree.set_column_title(4, "Rating")
	# The root node is hidden in the tree
	treerow = tree.create_item()
	treerow.set_text(0, "Hidden")
	treerow.set_text(1, "Hidden")
	treerow.set_text(2, "Hidden")
	treerow.set_text(3, "Hidden")
	treerow.set_text(4, "Hidden")
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://cfb.db"
	database.open_db()
	# Change label to include the name of the school
	var array1 : Array = database.select_rows("teams", "tid == " + str(team), ["school"])
	for row in array1:
		label.text = row["school"] + " Roster"
	print("Players:")
	# Select all rows from the table with the specified team ID
	var array2 : Array = database.select_rows("players", "tid == " + str(team), ["*"])
	for row in array2:
		# Create variable for tree row
		treerow = tree.create_item()
		# Convert jersey number to string
		var textJersey = str(row["jersey"])
		# Convert rating to string
		var textRating = str(row["rating"])
		# Print data to console
		print(row["firstname"])
		print(row["lastname"])
		print(row["position"])
		print(row["jersey"])
		print(row["rating"])
		# Add data to tree
		treerow.set_text(0, row["firstname"])
		treerow.set_text(1, row["lastname"])
		treerow.set_text(2, row["position"])
		treerow.set_text(3, textJersey)
		treerow.set_text(4, textRating)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_button_pressed():
	label.text = "Generating new teams table..."
	timer.start()

func _on_back_pressed():
	# Return to home screen when the back button is pressed
	get_tree().change_scene_to_file("res://teamselect.tscn")

func _on_timer_timeout():
	# Duplicate teams table when the "Choose School" button is pressed
	var new_table = {
		"tid" : {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		"cid" : {"data_type":"int"},
		"school" : {"data_type":"text"},
		"state" : {"data_type":"text"},
		"budget" : {"data_type":"int"},
		"prestige" : {"data_type":"int"},
		"ocid" : {"data_type":"int"},
		"dcid" : {"data_type":"int"},
		"ranking" : {"data_type":"int"},
		"wins" : {"data_type":"int"},
		"losses" : {"data_type":"int"}
	}
	database.query("DROP TABLE IF EXISTS teams1")
	database.create_table("teams1", new_table)
	database.query("SELECT * FROM teams")
	for i in database.query_result:
		var data = {
			"cid" : i["cid"],
			"school" : i["school"],
			"state" : i["state"],
			"budget" : i["budget"],
			"prestige" : i["prestige"],
			"ocid" : i["ocid"],
			"dcid" : i["dcid"],
			"ranking" : i["ranking"],
			"wins" : i["wins"],
			"losses" : i["losses"]
		}
		database.insert_row("teams1", data)
	# Go to offensive coordinator signing
	get_tree().change_scene_to_file("res://coachinfo.tscn")
