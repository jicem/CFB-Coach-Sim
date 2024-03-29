extends Control
var database : SQLite
var treerow : TreeItem
var team = Global.team
@onready var tree = $Tree
@onready var budget = %Budget
@onready var selection = $LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add column names for tree
	tree.set_column_title(0, "ID")
	tree.set_column_title(1, "First Name")
	tree.set_column_title(2, "Last Name")
	tree.set_column_title(3, "Rating")
	tree.set_column_title(4, "Desired Salary")
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
	# Change label to include the current school's budget
	var array1 : Array = database.select_rows("teams1", "tid == " + str(team), ["budget"])
	for row in array1:
		# Convert budget to formatted string
		var textBudget = add_commas(row["budget"])
		budget.text = "Budget: $" + textBudget
	# Select all rows from the table
	var array2 : Array = database.select_rows("offcoordinators", "", ["*"])
	for row in array2:
		# Create variable for tree row
		treerow = tree.create_item()
		# Convert jersey number to string
		var textID = str(row["ocid"])
		# Convert rating to string
		var textRating = str(row["rating"])
		# Convert salary to string
		var textSalary = str(row["salary"])
		# Add data to tree
		treerow.set_text(0, textID)
		treerow.set_text(1, row["firstname"])
		treerow.set_text(2, row["lastname"])
		treerow.set_text(3, textRating)
		treerow.set_text(4, textSalary)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_line_edit_text_submitted(new_text):
	if selection.text != "":
		var id = int(selection.text)
		if id > 0 and id < 81:
			var salary = 0
			var array1 : Array = database.select_rows("offcoordinators", "ocid == " + selection.text, ["salary"])
			for row in array1:
				salary = row["salary"]
			# Subtract the new coordinator's salary from the school's budget and replace it in the database
			var array2 : Array = database.select_rows("teams1", "tid == " + str(team), ["budget"])
			for row in array2:
				var newBudget = row["budget"] - salary
				if newBudget >= 0:
					database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
					print(newBudget)
					# Go to defensive coordinator signing
					get_tree().change_scene_to_file("res://dclist.tscn")
				else:
					# If newBudget is negative, give user an error
					selection.text = "ERR"
	else: pass

func _on_button_pressed():
	if selection.text != "":
		var id = int(selection.text)
		if id > 0 and id < 81:
			var salary = 0
			var array1 : Array = database.select_rows("offcoordinators", "ocid == " + selection.text, ["salary"])
			for row in array1:
				salary = row["salary"]
			# Subtract the new coordinator's salary from the school's budget and replace it in the database
			var array2 : Array = database.select_rows("teams1", "tid == " + str(team), ["budget"])
			for row in array2:
				var newBudget = row["budget"] - salary
				if newBudget >= 0:
					database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
					print(newBudget)
					# Go to defensive coordinator signing
					get_tree().change_scene_to_file("res://dclist.tscn")
				else:
					# If newBudget is negative, give user an error
					selection.text = "ERR"
	else: pass

func add_commas(number: int) -> String:
	var formatted_number = str(number)  # Convert integer to string
	var comma_index = formatted_number.length() - 3  # Get index of first comma

	# Insert commas after every three digits until the beginning of the string
	while comma_index > 0:
		formatted_number = formatted_number.insert(comma_index, ",")
		comma_index -= 3  # Move to the next comma position

	return formatted_number
