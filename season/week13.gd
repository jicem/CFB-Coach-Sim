extends Control
var ranking = 1
var season = 2024 + Global.season
var database : SQLite
@onready var button = $Button
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	button.hide()
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 13, Coach " + Global.coachname + ":"
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://cfb.db"
	database.open_db()
	# Updating rankings
	var query = "SELECT * FROM teams1 ORDER BY wins DESC, ranking ASC LIMIT 80"
	database.query(query)
	for i in database.query_result:
		# Assign ranking to new team starting with 1 and ending with 80
		database.update_rows("teams1", "tid == " + str(i["tid"]), {"ranking": ranking})
		# Increase ranking for next iteration
		ranking += 1
		
	# If the conference championship schedules haven't been done yet, do them here
	if Global.ccschedulecomplete == false:
		for i in range(8):
			var teamIds: Array = [] # Create an empty array to store team IDs for each conference
			var conference = i + 1
			# Query to calculate wins for each team in the current conference and sort them
			var winsQuery = "SELECT team_id, SUM(CASE WHEN homeTeamWon = 1 THEN 1 ELSE 0 END) AS wins
							FROM (SELECT homeTid AS team_id, homeTeamWon FROM schedule
							WHERE conference = " + str(conference) + " UNION ALL
							SELECT awayTid AS team_id, 1 - homeTeamWon FROM schedule
							WHERE conference = " + str(conference) + ") AS team_wins
							GROUP BY team_id ORDER BY wins DESC LIMIT 2"
			database.query(winsQuery)
			for j in database.query_result:
				# Add team ID to conference array
				teamIds.append(j["team_id"])
				
				# Add team ID to global array
				Global.postseasonIds.append(j["team_id"])
				
			var homeTid = teamIds[0]
			var awayTid = teamIds[1]
				
			# Print the result
			print(homeTid)
			print(awayTid)
				
			# Insert a new row into the schedule table
			var row_data = {
				"homeTid": homeTid,
				"awayTid": awayTid,
				"conference": conference,
				"week": 13,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
		
	# Only show the practice button if the player's team is active this week
	if Global.postseasonIds.has(Global.team):
		button.show()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	Global.week = 13
	get_tree().change_scene_to_file("res://season/practice.tscn")

func _on_button_2_pressed():
	Global.week = 13
	get_tree().change_scene_to_file("res://season/ccsimulation.tscn")

func _on_button_3_pressed():
	Global.week = 13
	get_tree().change_scene_to_file("res://season/ranking.tscn")

func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")
