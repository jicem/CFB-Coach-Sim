extends Control
var database : SQLite
var season = 2024 + Global.season
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	var available_ids
	var row_data
	var awayCount
	
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://cfb.db"
	database.open_db()
	
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 2, Coach " + Global.coachname + ":"

	# Create an array of numbers that the first loop will grab from
	available_ids = [21, 22, 23, 24, 27, 30, 31, 32, 33, 34, 37, 40]
	
	# Shuffle the array to randomize the order
	available_ids.shuffle()
	
	awayCount = 0 # Start counting used away values

	# Create a loop that inserts a new row into the schedule table 20 times
	for i in range(20):
		# Hard coding certain matchups
		if i == 4:
			# Team 5 will always play Team 8 in week 2
			row_data = {
				"homeTid": 5,
				"awayTid": 8,
				"conference": 1,
				"week": 2,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 7: continue
		if i == 5:
			# Team 6 will always play Team 9 in week 2
			row_data = {
				"homeTid": 6,
				"awayTid": 9,
				"conference": 1,
				"week": 2,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 8: continue
		if i == 14:
			# Team 15 will always play Team 18 in week 2
			row_data = {
				"homeTid": 15,
				"awayTid": 18,
				"conference": 2,
				"week": 2,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 17: continue
		if i == 15:
			# Team 16 will always play Team 19 in week 2
			row_data = {
				"homeTid": 16,
				"awayTid": 19,
				"conference": 2,
				"week": 2,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 18: continue

		# If there are no more available ids, break out of the loop
		if available_ids.size() == 0:
			break
		
		# Get the homeTid
		var home_tid = i + 1
		
		# Get the awayTid from the current index
		var away_tid = available_ids[awayCount]
		print("Home team: " + str(home_tid))
		print("Away team: " + str(away_tid))
		awayCount+=1

		# Insert the row into the schedule table
		row_data = {
			"homeTid": home_tid,
			"awayTid": away_tid,
			"conference": 0,
			"week": 2,
			"homeTeamWon": -1
		}
		database.insert_row("schedule", row_data)
	
	# Team 25 will always play Team 28 in week 2
	row_data = {
		"homeTid": 25,
		"awayTid": 28,
		"conference": 3,
		"week": 2,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 26 will always play Team 29 in week 2
	row_data = {
		"homeTid": 26,
		"awayTid": 29,
		"conference": 3,
		"week": 2,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 35 will always play Team 38 in week 2
	row_data = {
		"homeTid": 35,
		"awayTid": 38,
		"conference": 4,
		"week": 2,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 36 will always play Team 39 in week 2
	row_data = {
		"homeTid": 36,
		"awayTid": 39,
		"conference": 4,
		"week": 2,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
		
	# Create an array of numbers that the next loop will grab from
	available_ids = [61, 62, 63, 64, 67, 70, 71, 72, 73, 74, 77, 80]
	
	# Shuffle the array to randomize the order
	available_ids.shuffle()
	awayCount = 0 # Start counting used away values

	# Create a loop that inserts a new row into the schedule table 20 times
	for i in range(41, 61):
		# Hard coding certain matchups
		if i == 44:
			# Team 5 will always play Team 8 in week 2
			row_data = {
				"homeTid": 45,
				"awayTid": 48,
				"conference": 5,
				"week": 2,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 47: continue
		if i == 45:
			# Team 6 will always play Team 9 in week 2
			row_data = {
				"homeTid": 46,
				"awayTid": 49,
				"conference": 5,
				"week": 2,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 48: continue
		if i == 54:
			# Team 15 will always play Team 18 in week 2
			row_data = {
				"homeTid": 55,
				"awayTid": 58,
				"conference": 6,
				"week": 2,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 57: continue
		if i == 55:
			# Team 16 will always play Team 19 in week 2
			row_data = {
				"homeTid": 56,
				"awayTid": 59,
				"conference": 6,
				"week": 2,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 58: continue
		
		# Get the homeTid
		var home_tid = i + 1
		
		# Get the awayTid from the current index
		var away_tid = available_ids[awayCount]
		print("Home team: " + str(home_tid))
		print("Away team: " + str(away_tid))
		awayCount+=1

		# Insert the row into the schedule table
		row_data = {
			"homeTid": home_tid,
			"awayTid": away_tid,
			"conference": 0,
			"week": 2,
			"homeTeamWon": -1
		}
		database.insert_row("schedule", row_data)

	# Team 65 will always play Team 68 in week 2
	row_data = {
		"homeTid": 65,
		"awayTid": 68,
		"conference": 3,
		"week": 2,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 66 will always play Team 69 in week 2
	row_data = {
		"homeTid": 66,
		"awayTid": 69,
		"conference": 3,
		"week": 2,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 75 will always play Team 78 in week 2
	row_data = {
		"homeTid": 75,
		"awayTid": 78,
		"conference": 4,
		"week": 2,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 76 will always play Team 79 in week 2
	row_data = {
		"homeTid": 76,
		"awayTid": 79,
		"conference": 4,
		"week": 2,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_2_pressed():
	Global.week = 2
	get_tree().change_scene_to_file("res://season/simulation.tscn")


func _on_button_pressed():
	Global.week = 2
	get_tree().change_scene_to_file("res://season/practice.tscn")
