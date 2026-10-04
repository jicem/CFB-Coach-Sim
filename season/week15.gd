extends Control
var ranking = 1
var season = 2026 + Global.season
var database : SQLite
@onready var button = $Button
@onready var label = %Label
@onready var label2 = %Label2

func _ready():
	button.hide()
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 15, Coach " + Global.coachname + ":"
	# Open database
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	if Global.quarterschedulecomplete == false:
		# Reset postseason IDs
		Global.postseasonIds = []
		var row_data
		var playoff_winners = []

		# ------------------------------------------------
		# GET WINNERS FROM THE FOUR FIRST-ROUND GAMES
		# ------------------------------------------------

		var first_round_query = """
			SELECT homeTid, awayTid, homeTeamWon
			FROM schedule
			WHERE week = 14
			ORDER BY gid
			LIMIT 4
		"""

		database.query(first_round_query)
		for game in database.query_result:
			var winner
			if game["homeTeamWon"] == 1:
				winner = game["homeTid"]
			else:
				winner = game["awayTid"]
			playoff_winners.append(winner)
			Global.postseasonIds.append(winner)


		# ------------------------------------------------
		# GET THE TOP FOUR SEEDED TEAMS
		# ------------------------------------------------

		var top4query = """
			SELECT tid
			FROM teams1
			ORDER BY ranking ASC
			LIMIT 4
		"""
		database.query(top4query)
		var top4 = []
		for team_row in database.query_result:
			top4.append(team_row["tid"])


		# ------------------------------------------------
		# CREATE QUARTERFINAL MATCHUPS
		# ------------------------------------------------

		if playoff_winners.size() == 4 and top4.size() == 4:
			for i in range(4):
				var homeTid = top4[i]
				var awayTid = playoff_winners[i]
				row_data = {
					"homeTid": homeTid,
					"awayTid": awayTid,
					"conference": 0,
					"week": 15,
					"homeTeamWon": -1
				}
				database.insert_row("schedule", row_data)
				Global.quarterschedulecomplete = true
	# Only show the practice button if the player's team is active this week
	if Global.postseasonIds.has(Global.team):
		button.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	Global.week = 15
	get_tree().change_scene_to_file("res://season/practice.tscn")

func _on_button_2_pressed():
	Global.week = 15
	get_tree().change_scene_to_file("res://season/quartersimulation.tscn")


func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")


func _on_history_button_pressed():
	get_tree().change_scene_to_file("res://history.tscn")


func _on_achievement_button_pressed():
	get_tree().change_scene_to_file("res://achievements.tscn")
