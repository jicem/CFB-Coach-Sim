extends Control
var ranking = 1
var season = 2024 + Global.season
var database : SQLite
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 14, Coach " + Global.coachname + ":"
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
	var homeTid
	var awayTid
	var row_data
	var rowsArray = []
	# Select and sort the top 8 teams based on wins
	var top8query = "SELECT * FROM teams1 ORDER BY wins DESC, ranking ASC LIMIT 8"
	database.query(top8query)
	# Fetch and store the rows
	for i in database.query_result:
		rowsArray.append(i["tid"])
	# Check if there are at least 8 rows
	if rowsArray.size() >= 8:
		# Iterate through the rows and insert into the schedule table
		for i in range(4):
			homeTid = rowsArray[i]
			awayTid = rowsArray[7 - i]
			row_data = {
				"homeTid": homeTid,
				"awayTid": awayTid,
				"conference": 0,
				"week": 14,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			
	# Select the next 32 teams
	var rowCounter = 1; # Initialize a counter for rows
	var next32query = "SELECT * FROM teams1 ORDER BY wins DESC, ranking ASC LIMIT 32 OFFSET 8"
	database.query(next32query)
	for i in database.query_result:
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
