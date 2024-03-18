extends Control
var database : SQLite
var treerow : TreeItem
var team = Global.team
@onready var tree = $Tree
@onready var label = %Label

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add column names for tree and collapsible elements
	tree.set_column_title(0, "First Name")
	tree.set_column_title(1, "Last Name")
	tree.set_column_title(2, "Position")
	tree.set_column_title(3, "Jersey Number")
	tree.set_column_title(4, "Rating")
	treerow = tree.create_item()
	treerow.set_text(0, "Collapse")
	treerow.set_text(1, "Collapse")
	treerow.set_text(2, "Collapse")
	treerow.set_text(3, "Collapse")
	treerow.set_text(4, "Collapse")
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://cfb.db"
	database.open_db()
	# Change label to include the name of the school
	var array1 : Array = database.select_rows("teams", "tid == " + str(team), ["school"])
	for row in array1:
		label.text = row["school"] + " Roster"
	# Print players to console and add them to tree
	print("Players:")
	var array2 : Array = database.select_rows("players", "tid == " + str(team), ["*"])
	for row in array2:
		# Create variable for tree row
		treerow = tree.create_item()
		# Convert jersey number to string
		var textJersey = str(row["jersey"])
		# Convert rating to string
		var textRating = str(row["rating"])
		print(row["firstname"])
		print(row["lastname"])
		print(row["position"])
		print(row["jersey"])
		print(row["rating"])
		treerow.set_text(0, row["firstname"])
		treerow.set_text(1, row["lastname"])
		treerow.set_text(2, row["position"])
		treerow.set_text(3, textJersey)
		treerow.set_text(4, textRating)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_back_pressed():
	# Return to home screen when the back button is pressed
	get_tree().change_scene_to_file("res://teamselect.tscn")
