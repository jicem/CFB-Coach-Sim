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
	label2.text = "Here are your options for Week 16, Coach " + Global.coachname + ":"
	# Open database
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	if Global.semischedulecomplete == false:

		# Reset postseason IDs
		Global.postseasonIds = []

		var row_data
		var rowsArray = []

		# -----------------------------------------
		# GET THE FOUR WEEK 15 WINNERS
		# -----------------------------------------

		var semifinal_query = """SELECT homeTid, awayTid, homeTeamWon FROM schedule WHERE week = 15"""

		database.query(semifinal_query)
		for game in database.query_result:
			var winner
			if game["homeTeamWon"] == 1:
				winner = game["homeTid"]
			else:
				winner = game["awayTid"]
			rowsArray.append(winner)
			Global.postseasonIds.append(winner)


		# -----------------------------------------
		# CREATE THE TWO SEMIFINAL GAMES
		# -----------------------------------------

		if rowsArray.size() >= 4:
			for i in range(0, 4, 2):
				var homeTid = rowsArray[i]
				var awayTid = rowsArray[i + 1]
				row_data = {
					"homeTid": homeTid,
					"awayTid": awayTid,
					"conference": 0,
					"week": 16,
					"homeTeamWon": -1
				}
				database.insert_row("schedule", row_data)
				Global.semischedulecomplete = true
	# Only show the practice button if the player's team is active this week
	if Global.postseasonIds.has(Global.team):
		button.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	Global.week = 16
	get_tree().change_scene_to_file("res://season/practice.tscn")

func _on_button_2_pressed():
	Global.week = 16
	get_tree().change_scene_to_file("res://season/semisimulation.tscn")


func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")


func _on_history_button_pressed():
	get_tree().change_scene_to_file("res://history.tscn")


func _on_achievement_button_pressed():
	get_tree().change_scene_to_file("res://achievements.tscn")
