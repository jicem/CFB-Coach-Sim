extends Control
var database : SQLite
var treerow : TreeItem
var team = Global.team
@onready var tree = $Tree
@onready var button = $Button
@onready var selection = $LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add column names for tree
	tree.set_column_title(0, "ID")
	tree.set_column_title(1, "School")
	tree.set_column_title(2, "State")
	tree.set_column_title(3, "Conference")
	# The root node is hidden in the tree
	treerow = tree.create_item()
	treerow.set_text(0, "Hidden")
	treerow.set_text(1, "Hidden")
	treerow.set_text(2, "Hidden")
	treerow.set_text(3, "Hidden")
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	# Define conference names
	var conferenceNames = ['Elite 10 East', 'Elite 10 West', 'Big Dozen East', 'Big Dozen West',
						'South East', 'South West', 'Atlantic Coast', 'Champions',
						'National', 'Dixieland', 'Midwest', 'Great Lakes']
	# Change label to include the name of the school
	var array : Array = database.select_rows("teams", "tid < 121", ["*"])
	for row in array:
		var button = LinkButton.new()
		# Create variable for tree row
		treerow = tree.create_item()
		# Print data to console
		print(row["school"])
		print(row["state"])
		print(conferenceNames[row["cid"] - 1])
		# Add data to tree
		treerow.set_text(0, str(row["tid"]))
		treerow.set_text(1, row["school"])
		treerow.set_text(2, row["state"])
		treerow.set_text(3, conferenceNames[row["cid"] - 1])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_button_pressed():
	if selection.text != "":
		var id = int(selection.text)
		if id > 0 and id < 121:
			Global.team = selection.text
			get_tree().change_scene_to_file("res://playerlist.tscn")
	else: pass

func _on_line_edit_text_submitted(new_text):
	if selection.text != "":
		var id = int(selection.text)
		if id > 0 and id < 121:
			Global.team = selection.text
			get_tree().change_scene_to_file("res://playerlist.tscn")
	else: pass
	
func _on_tree_item_selected():
	selection.text = str(tree.get_selected().get_index() + 1)

func _on_title_pressed():
	get_tree().change_scene_to_file("res://titlescreen.tscn")
