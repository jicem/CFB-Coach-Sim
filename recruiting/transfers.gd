extends Control
var season = 2024 + Global.season
var team = Global.team
var database : SQLite
var treerow : TreeItem
@onready var label = %Label
@onready var tree = $Tree
@onready var budget = %Budget
@onready var needs = %Needs
@onready var selection = $LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add positions needed
	if Global.qbsneeded > 0: needs.text += "QB "
	if Global.rbsneeded > 0: needs.text += "RB "
	if Global.wrsneeded > 0: needs.text += "WR "
	if Global.tesneeded > 0: needs.text += "TE "
	if Global.olsneeded > 0: needs.text += "OL "
	if Global.dlsneeded > 0: needs.text += "DL "
	if Global.cbsneeded > 0: needs.text += "CB "
	if Global.lbsneeded > 0: needs.text += "LB "
	if Global.sneeded > 0: needs.text += "S "
	if Global.kneeded > 0: needs.text += "K "
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	generate_table()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Change label to include the current school's budget
	var array1 : Array = database.select_rows("teams1", "tid == " + str(team), ["budget"])
	for row in array1:
		# Convert budget to formatted string
		var textBudget = add_commas(row["budget"])
		budget.text = "Budget: $" + textBudget
		
func add_commas(number: int) -> String:
	var formatted_number = str(number)  # Convert integer to string
	var comma_index = formatted_number.length() - 3  # Get index of first comma

	# Insert commas after every three digits until the beginning of the string
	while comma_index > 0:
		formatted_number = formatted_number.insert(comma_index, ",")
		comma_index -= 3  # Move to the next comma position

	return formatted_number

func generate_table():
	# Add column names for tree
	tree.set_column_title(0, "ID")
	tree.set_column_title(1, "First Name")
	tree.set_column_title(2, "Last Name")
	tree.set_column_title(3, "Position")
	tree.set_column_title(4, "Age")
	tree.set_column_title(5, "Jersey Number")
	tree.set_column_title(6, "State")
	tree.set_column_title(7, "Rating")
	tree.set_column_title(8, "Cost to Sign")
	# The root node is hidden in the tree
	treerow = tree.create_item()
	for i in range(9):
		treerow.set_text(i, "Hidden")
	var numoftransfers = 1
	# Select all rows from the transfers table
	var array2 : Array = database.select_rows("transfers", "", ["*"])
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
		var nil = str("%0.2f" % row["nil"])
		# Convert rating to string
		var rating = str(row["rating"])
		# Add data to tree
		treerow.set_text(0, textID)
		treerow.set_text(1, row["firstname"])
		treerow.set_text(2, row["lastname"])
		treerow.set_text(3, row["position"])
		treerow.set_text(4, age)
		treerow.set_text(5, textJersey)
		treerow.set_text(6, row["state"])
		treerow.set_text(7, rating)
		treerow.set_text(8, nil)
		numoftransfers += 1

func _on_tree_item_selected():
	selection.text = tree.get_selected().get_text(0)

func _on_submit_button_pressed():
	if selection.text != "":
		var id = int(selection.text)
		var player_count_query = "SELECT COUNT(*) as count FROM transfers"
		database.query(player_count_query)
		for r in database.query_result:
			var upper = r["count"] + 1
			if id > 0 and id < upper:
				var salary = 0
				var array1 : Array = database.select_rows("transfers", "pid == " + selection.text, ["nil"])
				for row in array1:
					salary = row["nil"]
				# Subtract the new coordinator's salary from the school's budget and replace it in the database
				var array2 : Array = database.select_rows("teams1", "tid == " + str(team), ["budget"])
				for row in array2:
					var newBudget = row["budget"] - salary
					if newBudget >= 0:
						database.query("SELECT * FROM transfers WHERE pid == " + selection.text)
						for i in database.query_result:
							if i["position"] == "QB":
								if Global.qbsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.qbsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "RB":
								if Global.rbsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.rbsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "WR":
								if Global.wrsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.wrsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "TE":
								if Global.tesneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.tesneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "OL":
								if Global.olsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.olsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "DL":
								if Global.dlsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.dlsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "CB":
								if Global.cbsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.cbsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "LB":
								if Global.lbsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.lbsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "S":
								if Global.sneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.sneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "K":
								if Global.kneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.kneeded -= 1
								else: selection.text = "ERR"
					else:
						# If newBudget is negative, give user an error
						selection.text = "ERR"
		# Change positions needed
		needs.text = "Needs: "
		if Global.qbsneeded > 0: needs.text += "QB "
		if Global.rbsneeded > 0: needs.text += "RB "
		if Global.wrsneeded > 0: needs.text += "WR "
		if Global.tesneeded > 0: needs.text += "TE "
		if Global.olsneeded > 0: needs.text += "OL "
		if Global.dlsneeded > 0: needs.text += "DL "
		if Global.cbsneeded > 0: needs.text += "CB "
		if Global.lbsneeded > 0: needs.text += "LB "
		if Global.sneeded > 0: needs.text += "S "
		if Global.kneeded > 0: needs.text += "K "
	else: pass

func _on_line_edit_text_submitted(new_text):
	if selection.text != "":
		var id = int(selection.text)
		var player_count_query = "SELECT COUNT(*) as count FROM transfers"
		database.query(player_count_query)
		for r in database.query_result:
			var upper = r["count"] + 1
			if id > 0 and id < upper:
				var salary = 0
				var array1 : Array = database.select_rows("transfers", "pid == " + selection.text, ["nil"])
				for row in array1:
					salary = row["nil"]
				# Subtract the new coordinator's salary from the school's budget and replace it in the database
				var array2 : Array = database.select_rows("teams1", "tid == " + str(team), ["budget"])
				for row in array2:
					var newBudget = row["budget"] - salary
					if newBudget >= 0:
						database.query("SELECT * FROM transfers WHERE pid == " + selection.text)
						for i in database.query_result:
							if i["position"] == "QB":
								if Global.qbsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.qbsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "RB":
								if Global.rbsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.rbsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "WR":
								if Global.wrsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.wrsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "TE":
								if Global.tesneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.tesneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "OL":
								if Global.olsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.olsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "DL":
								if Global.dlsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.dlsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "CB":
								if Global.cbsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.cbsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "LB":
								if Global.lbsneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.lbsneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "S":
								if Global.sneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.sneeded -= 1
								else: selection.text = "ERR"
							elif i["position"] == "K":
								if Global.kneeded > 0:
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
									var delete_query = "DELETE FROM transfers WHERE pid = %d" % i["pid"]
									database.query(delete_query)
									tree.clear()
									generate_table()
									database.update_rows("teams1", "tid == " + str(team), {"budget": newBudget})
									print(newBudget)
									Global.kneeded -= 1
								else: selection.text = "ERR"
					else:
						# If newBudget is negative, give user an error
						selection.text = "ERR"
		# Change positions needed
		needs.text = "Needs: "
		if Global.qbsneeded > 0: needs.text += "QB "
		if Global.rbsneeded > 0: needs.text += "RB "
		if Global.wrsneeded > 0: needs.text += "WR "
		if Global.tesneeded > 0: needs.text += "TE "
		if Global.olsneeded > 0: needs.text += "OL "
		if Global.dlsneeded > 0: needs.text += "DL "
		if Global.cbsneeded > 0: needs.text += "CB "
		if Global.lbsneeded > 0: needs.text += "LB "
		if Global.sneeded > 0: needs.text += "S "
		if Global.kneeded > 0: needs.text += "K "
	else: pass

func _on_button_pressed():
	for i in range(6):
		# Add players to each team with less than 23 roster spots
		var array : Array = database.select_rows("teams1", "prestige > 80", ["*"])
		for row in array:
			var current_tid = row["tid"]
			if current_tid == Global.team: continue
			var player_count_query = "SELECT COUNT(*) as count FROM players1 WHERE tid = %d" % current_tid
			database.query(player_count_query)
			for r in database.query_result:
				if r["count"] < 23:
					var player_sort_query = "SELECT * FROM transfers ORDER BY rating DESC"
					database.query(player_sort_query)
					var p = database.query_result
					var data = {
						"firstname" : p[0]["firstname"],
						"lastname" : p[0]["lastname"],
						"tid" : row["tid"],
						"birthyear" : p[0]["birthyear"],
						"position" : p[0]["position"],
						"jersey" : p[0]["jersey"],
						"state" : p[0]["state"],
						"rating" : p[0]["rating"]
					}
					database.insert_row("players1", data)
					print(row["school"], " has ", r["count"], " players.")
					var delete_query = "DELETE FROM transfers WHERE pid = %d" % p[0]["pid"]
					database.query(delete_query)
	for i in range(6):
		# Add players to each team with less than 22 roster spots
		var array : Array = database.select_rows("teams1", "prestige <= 80", ["*"])
		for row in array:
			var current_tid = row["tid"]
			if current_tid == Global.team: continue
			var player_count_query = "SELECT COUNT(*) as count FROM players1 WHERE tid = %d" % current_tid
			database.query(player_count_query)
			for r in database.query_result:
				if r["count"] < 23:
					var player_sort_query = "SELECT * FROM transfers"
					database.query(player_sort_query)
					var p = database.query_result
					if p.size() > 0:
						var selected_recruit = p[0]
						var data = {
							"firstname" : selected_recruit["firstname"],
							"lastname" : selected_recruit["lastname"],
							"tid" : row["tid"],
							"birthyear" : selected_recruit["birthyear"],
							"position" : selected_recruit["position"],
							"jersey" : selected_recruit["jersey"],
							"state" : selected_recruit["state"],
							"rating" : selected_recruit["rating"]
						}
						database.insert_row("players1", data)
						var delete_query = "DELETE FROM transfers WHERE pid = %d" % selected_recruit["pid"]
						database.query(delete_query)
	get_tree().change_scene_to_file("res://recruiting/coordinators.tscn")
