extends Control
var season = 2024 + Global.season
var team = Global.team
var database : SQLite
var treerow : TreeItem
@onready var tree = $Tree
@onready var budget = %Budget
@onready var selection = $LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add column names for tree
	tree.set_column_title(0, "ID")
	tree.set_column_title(1, "First Name")
	tree.set_column_title(2, "Last Name")
	tree.set_column_title(3, "Age")
	tree.set_column_title(4, "Jersey Number")
	tree.set_column_title(5, "State")
	tree.set_column_title(6, "Rating")
	tree.set_column_title(7, "Cost to Sign")
	# The root node is hidden in the tree
	treerow = tree.create_item()
	for i in range(8):
		treerow.set_text(i, "Hidden")
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	# Change label to include the current school's budget
	var array1 : Array = database.select_rows("teams1", "tid == " + str(team), ["budget"])
	for row in array1:
		# Convert budget to formatted string
		var textBudget = add_commas(row["budget"])
		budget.text = "Budget: $" + textBudget
	# Select all rows from the table with the current team ID
	var array2 : Array = database.select_rows("recruits", "position == 'TE'", ["*"])
	for row in array2:
		# Create variable for tree row
		treerow = tree.create_item()
		# Convert jersey number to string
		var textID = str(row["pid"])
		# Convert jersey number to string
		var textJersey = str(row["jersey"])
		# Convert age to string
		var age = str(season - row["birthyear"])
		# Convert NIL to string
		var nil = "%.2f" % float(row["nil"])
		# Determine star rating based on the value of "rating"
		var rating = row["rating"]
		var starRating = match_rating_to_stars(rating)
		# Add data to tree
		treerow.set_text(0, textID)
		treerow.set_text(1, row["firstname"])
		treerow.set_text(2, row["lastname"])
		treerow.set_text(3, age)
		treerow.set_text(4, textJersey)
		treerow.set_text(5, row["state"])
		treerow.set_text(6, starRating)
		treerow.set_text(7, nil)
		
func add_commas(number: int) -> String:
	var formatted_number = str(number)  # Convert integer to string
	var comma_index = formatted_number.length() - 3  # Get index of first comma

	# Insert commas after every three digits until the beginning of the string
	while comma_index > 0:
		formatted_number = formatted_number.insert(comma_index, ",")
		comma_index -= 3  # Move to the next comma position

	return formatted_number
		
func match_rating_to_stars(rating):
	if rating > 85:
		return "⭐⭐⭐⭐⭐"
	elif rating > 70:
		return "⭐⭐⭐⭐"
	elif rating > 55:
		return "⭐⭐⭐"
	elif rating > 40:
		return "⭐⭐"
	else:
		return "⭐"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_submit_button_pressed():
	if selection.text != "":
		var id = int(selection.text)
		if id > 200 and id < 241:
			var salary = 0
			var array1 : Array = database.select_rows("recruits", "pid == " + selection.text, ["nil"])
			for row in array1:
				salary = row["nil"]
			# Subtract the new coordinator's salary from the school's budget and replace it in the database
			var array2 : Array = database.select_rows("teams1", "tid == " + str(team), ["budget"])
			for row in array2:
				var newBudget = row["budget"] - salary
				if newBudget >= 0:
					database.query("SELECT * FROM recruits WHERE pid == " + selection.text)
					for i in database.query_result:
						var data = {
							"firstname" : i["firstname"],
							"lastname" : i["lastname"],
							"tid" : team,
							"birthyear" : i["birthyear"],
							"position" : i["position"],
							"jersey" : i["jersey"],
							"state" : i["state"],
							"rating" : i["rating"]
						}
						database.insert_row("players1", data)
						var delete_query = "DELETE FROM recruits WHERE pid = %d" % i["pid"]
						database.query(delete_query)
					database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
					print(newBudget)
					# Go to high school recruiting
					Global.tesneeded -= 1
					get_tree().change_scene_to_file("res://recruiting/hs.tscn")
				else:
					# If newBudget is negative, give user an error
					selection.text = "ERR"
	else: pass


func _on_line_edit_text_submitted(new_text):
	if selection.text != "":
		var id = int(selection.text)
		if id > 200 and id < 241:
			var salary = 0
			var array1 : Array = database.select_rows("recruits", "pid == " + selection.text, ["nil"])
			for row in array1:
				salary = row["nil"]
			# Subtract the new coordinator's salary from the school's budget and replace it in the database
			var array2 : Array = database.select_rows("teams1", "tid == " + str(team), ["budget"])
			for row in array2:
				var newBudget = row["budget"] - salary
				if newBudget >= 0:
					database.query("SELECT * FROM recruits WHERE pid == " + selection.text)
					for i in database.query_result:
						var data = {
							"firstname" : i["firstname"],
							"lastname" : i["lastname"],
							"tid" : team,
							"birthyear" : i["birthyear"],
							"position" : i["position"],
							"jersey" : i["jersey"],
							"state" : i["state"],
							"rating" : i["rating"]
						}
						database.insert_row("players1", data)
						var delete_query = "DELETE FROM recruits WHERE pid = %d" % i["pid"]
						database.query(delete_query)
					database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
					print(newBudget)
					# Go to high school recruiting
					Global.tesneeded -= 1
					get_tree().change_scene_to_file("res://recruiting/hs.tscn")
				else:
					# If newBudget is negative, give user an error
					selection.text = "ERR"
	else: pass
	


func _on_skip_button_pressed():
	get_tree().change_scene_to_file("res://recruiting/hs.tscn")


func _on_tree_item_selected():
	selection.text = tree.get_selected().get_text(0)
