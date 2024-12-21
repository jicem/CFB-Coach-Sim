extends Control
var season = 2024 + Global.season
var database : SQLite
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.state = 1
	var t = str(Global.team)
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 1, Coach " + Global.coachname + ":"
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	# Set wins and losses to 0 for every team
	database.query("UPDATE teams1 SET wins = 0, losses = 0")
	# Assign random offensive and defensive coordinators to other teams and empty player stats table
	database.query("UPDATE teams1 SET dcid = abs(RANDOM()) % (80 - 1) + 1, ocid = abs(RANDOM()) % (80 - 1) + 1 WHERE tid <> " + t)
	database.query("DELETE FROM player_stats")
	var season_count_query = "SELECT COUNT(*) as count FROM seasons"
	database.query(season_count_query)
	for i in database.query_result:
		if i["count"] == Global.season:
			var data = {
				"winner" : null,
				"loser" : null,
				"coachteam" : Global.team,
				"coachname" : Global.coachname,
				"coachface" : Global.face,
				"offense" : Global.offense,
				"defense" : Global.defense,
				"admood" : Global.admood,
				"playhrs" : Global.playhrs,
				"playmins" : Global.playmins
			}
			database.insert_row("seasons", data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_2_pressed():
	Global.week = 1
	get_tree().change_scene_to_file("res://season/simulation.tscn")


func _on_button_pressed():
	Global.week = 1
	get_tree().change_scene_to_file("res://season/practice.tscn")


func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")

func _on_history_button_pressed():
	get_tree().change_scene_to_file("res://history.tscn")


func _on_achievement_button_pressed():
	get_tree().change_scene_to_file("res://achievements.tscn")
