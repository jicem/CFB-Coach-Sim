extends Node2D
var database : SQLite

# Called when the node enters the scene tree for the first time.
func _ready():
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	get_tree().change_scene_to_file("res://schoolselection.tscn")


func _on_guide_pressed():
	get_tree().change_scene_to_file("res://guide1.tscn")


func _on_button_2_pressed():
	database.import_from_json("res://data/save")
	var season_count_query = "SELECT COUNT(*) as count FROM seasons"
	database.query(season_count_query)
	for i in database.query_result:
		Global.season = i["count"]
		var array : Array = database.select_rows("seasons", "sid = " + str(Global.season), ["*"])
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
