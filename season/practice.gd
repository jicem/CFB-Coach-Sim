extends Control
var season = 2024 + Global.season
var team = Global.team
var treerow : TreeItem
var database : SQLite
@onready var tree = $Tree
@onready var label = %Label

# Called when the node enters the scene tree for the first time.
func _ready():
	# Import the RandomNumberGenerator class
	var rng = RandomNumberGenerator.new()
	rng.randomize()  # Seed the random number generator
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	# Add column names for tree
	tree.set_column_title(0, "First Name")
	tree.set_column_title(1, "Last Name")
	tree.set_column_title(2, "Position")
	tree.set_column_title(3, "Jersey Number")
	tree.set_column_title(4, "Old Rating")
	tree.set_column_title(5, "New Rating")
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
	print("Players:")
	# Select all rows from the table with the specified team ID
	var array2 : Array = database.select_rows("players1", "tid == " + str(team), ["*"])
	for row in array2:
		var rating = row["rating"]
		# Create variable for tree row
		treerow = tree.create_item()
		# Convert jersey number to string
		var textJersey = str(row["jersey"])
		# Convert rating to string
		var textRating = str(rating)
		print("Old Rating: " + textRating)
		# Add data to tree
		treerow.set_text(0, row["firstname"])
		treerow.set_text(1, row["lastname"])
		treerow.set_text(2, row["position"])
		treerow.set_text(3, textJersey)
		treerow.set_text(4, textRating)
		# Determine whether to increase the rating by 1
		if rng.randf() < 0.5 and rating < 99:
			rating += 1
		textRating = str(rating)
		print("New Rating: " + textRating)
		database.update_rows("players1", "pid == " + str(row["pid"]), {"rating": rating})
		# Display the new rating in the table
		treerow.set_text(5, textRating)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	if(Global.week == 13):
		get_tree().change_scene_to_file("res://season/ccsimulation.tscn")
	elif(Global.week == 14):
		get_tree().change_scene_to_file("res://season/bowlsimulation.tscn")
	elif(Global.week == 15):
		get_tree().change_scene_to_file("res://season/semisimulation.tscn")
	elif(Global.week == 16):
		get_tree().change_scene_to_file("res://season/finalsimulation.tscn")
	else:
		get_tree().change_scene_to_file("res://season/simulation.tscn")
