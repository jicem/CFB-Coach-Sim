extends Control
var season = 2026 + Global.season
var team = Global.team
var database : SQLite
var treerow : TreeItem
@onready var option = $OptionButton
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
	tree.set_column_title(4, "Jersey")
	tree.set_column_title(5, "State")
	tree.set_column_title(6, "Rating")
	tree.set_column_title(7, "Cost to Sign")
	tree.set_column_custom_minimum_width(1, 130)  # First Name
	tree.set_column_custom_minimum_width(2, 130)  # Last Name
	tree.set_column_custom_minimum_width(3, 50)   # Age
	tree.set_column_custom_minimum_width(4, 50)   # Jersey Number
	tree.set_column_custom_minimum_width(5, 50)   # State Abbreviation
	tree.set_column_custom_minimum_width(6, 120)  # Rating
	tree.set_column_custom_minimum_width(7, 120)  # Cost to Sign
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
	# Populate the state dropdown
	populate_state_filter()
	# Populate the recruit table
	populate_recruits()
		
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


func populate_state_filter():
	option.clear()

	# Add an option to show all recruits
	option.add_item("All States")

	# Get all state abbreviations in alphabetical order
	database.query("SELECT DISTINCT abbrev FROM states ORDER BY abbrev ASC")

	for row in database.query_result:
		option.add_item(row["abbrev"])

	# Default to All States
	option.select(0)


func populate_recruits():
	# Clear existing recruit rows but keep the hidden root
	tree.clear()
	treerow = tree.create_item()

	for i in range(8):
		treerow.set_text(i, "Hidden")

	# Get the selected state
	var selected_state = option.get_item_text(option.selected)

	var query = "SELECT * FROM recruits WHERE position = 'OL'"

	# Apply the state filter unless All States is selected
	if selected_state != "All States":
		query += " AND state = '" + selected_state + "'"

	query += " ORDER BY pid ASC"

	database.query(query)

	for row in database.query_result:
		treerow = tree.create_item()

		var text_id = str(row["pid"])
		var text_jersey = str(row["jersey"])
		var age = str(season - row["birthyear"])
		var nil_value = "$" + add_commas(int(row["nil"]))
		var star_rating = match_rating_to_stars(row["rating"])

		treerow.set_text(0, text_id)
		treerow.set_text(1, row["firstname"])
		treerow.set_text(2, row["lastname"])
		treerow.set_text(3, age)
		treerow.set_text(4, text_jersey)
		treerow.set_text(5, row["state"])
		treerow.set_text(6, star_rating)
		treerow.set_text(7, nil_value)

func _on_submit_button_pressed():
	if selection.text != "":
		var id = int(selection.text)
		if id > 300 and id < 551:
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
					Global.olsneeded -= 1
					get_tree().change_scene_to_file("res://recruiting/hs.tscn")
				else:
					# If newBudget is negative, give user an error
					selection.text = "ERR"
	else: pass


func _on_line_edit_text_submitted(new_text):
	if selection.text != "":
		var id = int(selection.text)
		if id > 300 and id < 551:
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
					Global.olsneeded -= 1
					get_tree().change_scene_to_file("res://recruiting/hs.tscn")
				else:
					# If newBudget is negative, give user an error
					selection.text = "ERR"
	else: pass
	


func _on_skip_button_pressed():
	get_tree().change_scene_to_file("res://recruiting/hs.tscn")


func _on_tree_item_selected():
	selection.text = tree.get_selected().get_text(0)


func _on_option_button_item_selected(index):
	populate_recruits()
