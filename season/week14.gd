extends Control
var ranking = 1
var season = 2026 + Global.season
var database : SQLite
@onready var button = $Button
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	button.hide()
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 14, Coach " + Global.coachname + ":"
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	# Updating rankings
	var query = "SELECT * FROM teams1 ORDER BY wins DESC, ranking ASC"
	database.query(query)
	for i in database.query_result:
		# Assign ranking to new team starting with 1 and ending with 80
		database.update_rows("teams1", "tid == " + str(i["tid"]), {"ranking": ranking})
		# Increase ranking for next iteration
		ranking += 1
		
	# If the playoff schedule hasn't been created yet, do it here
	if Global.bowlschedulecomplete == false:

		# Reset postseason IDs
		Global.postseasonIds = []
		var homeTid
		var awayTid
		var row_data
		var rowsArray = []

		# --------------------------------
		# GET TOP 12 TEAMS
		# --------------------------------

		var playoff_query = """
			SELECT *
			FROM teams1
			ORDER BY ranking ASC
			LIMIT 12
		"""

		database.query(playoff_query)

		# Store playoff teams in seed order
		for row in database.query_result:
			rowsArray.append(row["tid"])
			Global.postseasonIds.append(row["tid"])


		# --------------------------------
		# MAKE SURE WE HAVE 12 TEAMS
		# --------------------------------

		if rowsArray.size() >= 12:

			# --------------------------------
			# FIRST ROUND
			# --------------------------------

			# #5 vs #12
			row_data = {
				"homeTid": rowsArray[4],
				"awayTid": rowsArray[11],
				"conference": 0,
				"week": 14,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)

			# #6 vs #11
			row_data = {
				"homeTid": rowsArray[5],
				"awayTid": rowsArray[10],
				"conference": 0,
				"week": 14,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)

			# #7 vs #10
			row_data = {
				"homeTid": rowsArray[6],
				"awayTid": rowsArray[9],
				"conference": 0,
				"week": 14,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)

			# #8 vs #9
			row_data = {
				"homeTid": rowsArray[7],
				"awayTid": rowsArray[8],
				"conference": 0,
				"week": 14,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)

		# Select the next 32 teams
		var rowCounter = 1; # Initialize a counter for rows
		var next32query = "SELECT * FROM teams1 ORDER BY wins DESC, ranking ASC LIMIT 32 OFFSET 12"
		database.query(next32query)
		for i in database.query_result:
			Global.postseasonIds.append(i["tid"])
			print(rowCounter)
			# If the current row count is odd, only set the homeTid value for this iteration
			if rowCounter % 2 == 1:
				homeTid = i["tid"]
			# If the current row count is even, set the awayTid value and insert both into the table
			else:
				awayTid = i["tid"]
				row_data = {
					"homeTid": homeTid,
					"awayTid": awayTid,
					"conference": 0,
					"week": 14,
					"homeTeamWon": -1
				}
				database.insert_row("schedule", row_data)
			# Increment the row counter
			rowCounter += 1

	# Only show the practice button if the player's team is active this week
	if Global.postseasonIds.has(Global.team):
		button.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	Global.week = 14
	get_tree().change_scene_to_file("res://season/practice.tscn")

func _on_button_2_pressed():
	Global.week = 14
	get_tree().change_scene_to_file("res://season/bowlsimulation.tscn")

func _on_button_3_pressed():
	Global.week = 14
	get_tree().change_scene_to_file("res://season/ranking.tscn")

func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")


func _on_history_button_pressed():
	get_tree().change_scene_to_file("res://history.tscn")


func _on_achievement_button_pressed():
	get_tree().change_scene_to_file("res://achievements.tscn")
