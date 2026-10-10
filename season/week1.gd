extends Control
var season = 2026 + Global.season
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

	# --------------------------------------------------
	# ASSIGN OFFENSIVE COORDINATORS
	# --------------------------------------------------

	# Get teams sorted by prestige, highest first
	var teams_by_prestige = database.select_rows(
		"teams1",
		"tid <> " + t,
		["*"]
	)

	# Sort the teams by prestige descending
	teams_by_prestige.sort_custom(
		func(a, b):
			if a["prestige"] == b["prestige"]:
				return a["tid"] < b["tid"]
			return a["prestige"] > b["prestige"]
	)

	# Get offensive coordinators sorted by rating
	var offensive_coordinators = database.select_rows(
		"offcoordinators",
		"",
		["*"]
	)

	offensive_coordinators.sort_custom(
		func(a, b):
			if a["rating"] == b["rating"]:
				return a["ocid"] < b["ocid"]
			return a["rating"] > b["rating"]
	)

	# Assign coordinators
	for rank in range(teams_by_prestige.size()):

		var team_row = teams_by_prestige[rank]
		var tid = team_row["tid"]

		# Every four teams, decrease the elite-coordinator
		# probability by 1 percentage point.
		#
		# #1-4   = 32%
		# #5-8   = 31%
		# #9-12  = 30%
		# ...
		# #125-128 = 1%
		# #129      = 0%
		var top_probability = 32 - int(rank / 4)

		top_probability = clamp(
			top_probability,
			0,
			32
		)

		var ocid

		# Random number from 0 to 99
		var roll = randi_range(0, 99)

		if roll < top_probability:

			# ------------------------------------------
			# TOP 20 OFFENSIVE COORDINATORS
			# ------------------------------------------

			var index = randi_range(
				0,
				min(19, offensive_coordinators.size() - 1)
			)

			ocid = offensive_coordinators[index]["ocid"]

		else:

			# ------------------------------------------
			# BOTTOM 60 OFFENSIVE COORDINATORS
			# ------------------------------------------

			var bottom_start = min(
				20,
				offensive_coordinators.size()
			)

			var bottom_end = offensive_coordinators.size() - 1

			var index = randi_range(
				bottom_start,
				bottom_end
			)

			ocid = offensive_coordinators[index]["ocid"]

		# Assign coordinator
		database.update_rows(
			"teams1",
			"tid = " + str(tid),
			{"ocid": ocid}
		)

	# --------------------------------------------------
	# ASSIGN DEFENSIVE COORDINATORS
	# --------------------------------------------------

	# Get defensive coordinators sorted by rating
	var defensive_coordinators = database.select_rows(
		"defcoordinators",
		"",
		["*"]
	)
	
	defensive_coordinators.sort_custom(
		func(a, b):
			if a["rating"] == b["rating"]:
				return a["dcid"] < b["dcid"]
			return a["rating"] > b["rating"]
	)
	
	# Assign coordinators
	for rank in range(teams_by_prestige.size()):

		var team_row = teams_by_prestige[rank]
		var tid = team_row["tid"]

		# #1-4 = 32%
		# #5-8 = 31%
		# ...
		# #125-128 = 1%
		# #129 = 0%
		var top_probability = 32 - int(rank / 4)

		top_probability = clamp(
			top_probability,
			0,
			32
		)

		var dcid

		var roll = randi_range(0, 99)

		if roll < top_probability:

			# ------------------------------------------
			# TOP 20 DEFENSIVE COORDINATORS
			# ------------------------------------------

			var index = randi_range(
				0,
				min(19, defensive_coordinators.size() - 1)
			)

			dcid = defensive_coordinators[index]["dcid"]

		else:

			# ------------------------------------------
			# BOTTOM 60 DEFENSIVE COORDINATORS
			# ------------------------------------------

			var bottom_start = min(
				20,
				defensive_coordinators.size()
			)

			var bottom_end = defensive_coordinators.size() - 1

			var index = randi_range(
				bottom_start,
				bottom_end
			)

			dcid = defensive_coordinators[index]["dcid"]

		# Assign coordinator
		database.update_rows(
			"teams1",
			"tid = " + str(tid),
			{"dcid": dcid}
		)

	# Empty player stats table
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
