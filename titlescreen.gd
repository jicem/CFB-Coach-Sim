extends Node2D

var database : SQLite

@onready var savedgames = $SavedGames
@onready var savedgamelist = $SavedGames/ItemList


func _ready():
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()

	# Populate saved games list
	load_saved_games()


func _process(delta):
	pass


func load_saved_games():
	savedgamelist.clear()

	var saves = {}

	# Search the persistent user directory first
	add_saves_from_directory("user://accfb_data", saves)

	# Include saves from the project data directory
	add_saves_from_directory("res://data", saves)

	# Sort the displayed names
	var save_names = saves.keys()
	save_names.sort()

	for save_name in save_names:
		var item_index = savedgamelist.add_item(
			save_name.replace("_", " ")
		)

		# Store the complete path to the save file
		savedgamelist.set_item_metadata(
			item_index,
			saves[save_name]
		)


func add_saves_from_directory(path: String, saves: Dictionary):
	var dir = DirAccess.open(path)

	if dir == null:
		return

	dir.list_dir_begin()

	var filename = dir.get_next()

	while filename != "":
		if not dir.current_is_dir():
			if filename.get_extension().to_lower() == "json":
				var save_name = filename.get_basename()

				# Prefer the first occurrence of a save name.
				# Since user://data is searched first, it takes priority.
				if not saves.has(save_name):
					saves[save_name] = path.path_join(filename)

		filename = dir.get_next()

	dir.list_dir_end()


func _on_button_pressed():
	get_tree().change_scene_to_file("res://schoolselection.tscn")


func _on_guide_pressed():
	get_tree().change_scene_to_file("res://guide1.tscn")


func _on_quit_pressed():
	get_tree().quit()


func _on_load_pressed():
	# Refresh saves before displaying the popup
	load_saved_games()
	savedgames.popup_centered()


func _on_button_1_pressed():
	var selected = savedgamelist.get_selected_items()

	if selected.size() == 0:
		return

	# Retrieve the full save path
	var filepath = savedgamelist.get_item_metadata(selected[0])

	# Set the global save name without the directory or extension
	Global.savename = filepath.get_file().get_basename()

	# Import the selected save
	database.import_from_json(filepath)

	# Determine the current season
	database.query("SELECT COUNT(*) AS count FROM seasons")

	for result in database.query_result:
		Global.season = int(result["count"])

		var array: Array = database.select_rows(
			"seasons",
			"sid = " + str(Global.season),
			["*"]
		)

		for row in array:
			Global.team = row["coachteam"]
			Global.coachname = row["coachname"]
			Global.face = row["coachface"]
			Global.offense = row["offense"]
			Global.defense = row["defense"]
			Global.admood = row["admood"]
			Global.playhrs = row["playhrs"]
			Global.playmins = row["playmins"]

	get_tree().change_scene_to_file("res://newseason.tscn")


func _on_button_2_pressed():
	savedgames.hide()
