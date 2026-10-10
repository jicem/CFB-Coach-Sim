extends Control
var database : SQLite
@onready var timer = $Timer
@onready var prompt = %Prompt
@onready var savegame = $SaveGame
@onready var inputname = $SaveGame/LineEdit

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.season += 1

	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()

	# Get the user's team name
	var team_name = ""

	var team_array : Array = database.select_rows(
		"teams1",
		"tid = " + str(Global.team),
		["school"]
	)

	if team_array.size() > 0:
		team_name = team_array[0]["school"]

	# Set default save name
	inputname.text = team_name + " " + str(2026 + Global.season)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_yes_pressed():
	if Global.savename == null or Global.savename == "":
		savegame.popup_centered()
	else:
		save_game(Global.savename + ".json")
		prompt.text = "Saving game and starting new season..."
		timer.start()

func _on_no_pressed():
	# Go to new game screen
	prompt.text = "Starting new season..."
	timer.start()

func _on_timer_timeout():
	get_tree().change_scene_to_file("res://newseason.tscn")


func _on_button_pressed():
	# Replace spaces with underscores
	var filename = inputname.text.strip_edges().replace(" ", "_")

	if filename == "":
		return

	# Save under the same filename in both locations
	Global.savename = filename
	save_game(filename + ".json")

	prompt.text = "Saving game and starting new season..."
	timer.start()


func save_game(filename: String):
	# Ensure the user data directory exists
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path("user://accfb_data")
	)

	# Export to the project data folder
	database.export_to_json("res://data/" + filename)

	# Export to the user's persistent data folder
	database.export_to_json("user://accfb_data/" + filename)
