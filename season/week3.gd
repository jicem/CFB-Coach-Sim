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
	label2.text = "Here are your options for Week 3, Coach " + Global.coachname + ":"

	# Create an array of numbers that the loop will grab from
	available_ids = [41, 42, 44, 48, 51, 52, 54, 58, 61, 62, 64, 68, 71, 72, 74, 78]
	
	# Shuffle the array to randomize the order
	available_ids.shuffle()
	
	awayCount = 0 # Start counting used away values
	
	# Create a loop that inserts a new row into the schedule table 38 times
	for i in range(38):
		# Hard coding certain matchups
		if i == 2:
			# Team 3 will always play Team 7 in week 3
			row_data = {
				"homeTid": 3,
				"awayTid": 7,
				"conference": 1,
				"week": 3,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 6: continue
		if i == 4:
			# Team 5 will always play Team 9 in week 3
			row_data = {
				"homeTid": 5,
				"awayTid": 9,
				"conference": 1,
				"week": 3,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 8: continue
		if i == 5:
			# Team 6 will always play Team 10 in week 3
			row_data = {
				"homeTid": 6,
				"awayTid": 10,
				"conference": 1,
				"week": 3,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 9: continue
		if i == 12:
			# Team 13 will always play Team 17 in week 3
			row_data = {
				"homeTid": 13,
				"awayTid": 17,
				"conference": 2,
				"week": 3,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 16: continue
		if i == 14:
			# Team 15 will always play Team 19 in week 3
			row_data = {
				"homeTid": 15,
				"awayTid": 19,
				"conference": 2,
				"week": 3,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 18: continue
		if i == 15:
			# Team 16 will always play Team 20 in week 3
			row_data = {
				"homeTid": 16,
				"awayTid": 20,
				"conference": 2,
				"week": 3,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 19: continue
		if i == 22:
			# Team 23 will always play Team 27 in week 3
			row_data = {
				"homeTid": 23,
				"awayTid": 27,
				"conference": 3,
				"week": 3,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 26: continue
		if i == 24:
			# Team 25 will always play Team 29 in week 3
			row_data = {
				"homeTid": 25,
				"awayTid": 29,
				"conference": 3,
				"week": 3,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 28: continue
		if i == 25:
			# Team 26 will always play Team 30 in week 3
			row_data = {
				"homeTid": 26,
				"awayTid": 30,
				"conference": 3,
				"week": 3,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 29: continue
		if i == 32:
			# Team 33 will always play Team 37 in week 3
			row_data = {
				"homeTid": 33,
				"awayTid": 37,
				"conference": 4,
				"week": 3,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 36: continue
		if i == 34:
			# Team 35 will always play Team 39 in week 3
			row_data = {
				"homeTid": 35,
				"awayTid": 39,
				"conference": 4,
				"week": 3,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue
		if i == 35:
			# Team 36 will always play Team 40 in week 3
			row_data = {
				"homeTid": 36,
				"awayTid": 40,
				"conference": 4,
				"week": 3,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
			continue

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
			"week": 3,
			"homeTeamWon": -1
		}
		database.insert_row("schedule", row_data)
		
	# Team 43 will always play Team 47 in week 3
	row_data = {
		"homeTid": 43,
		"awayTid": 47,
		"conference": 5,
		"week": 3,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 45 will always play Team 49 in week 3
	row_data = {
		"homeTid": 45,
		"awayTid": 49,
		"conference": 5,
		"week": 3,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 46 will always play Team 50 in week 3
	row_data = {
		"homeTid": 46,
		"awayTid": 50,
		"conference": 5,
		"week": 3,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 53 will always play Team 57 in week 3
	row_data = {
		"homeTid": 53,
		"awayTid": 57,
		"conference": 6,
		"week": 3,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 55 will always play Team 59 in week 3
	row_data = {
		"homeTid": 55,
		"awayTid": 59,
		"conference": 6,
		"week": 3,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 56 will always play Team 60 in week 3
	row_data = {
		"homeTid": 56,
		"awayTid": 60,
		"conference": 6,
		"week": 3,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 63 will always play Team 67 in week 3
	row_data = {
		"homeTid": 63,
		"awayTid": 67,
		"conference": 7,
		"week": 3,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 65 will always play Team 69 in week 3
	row_data = {
		"homeTid": 65,
		"awayTid": 69,
		"conference": 7,
		"week": 3,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 66 will always play Team 70 in week 3
	row_data = {
		"homeTid": 66,
		"awayTid": 70,
		"conference": 5,
		"week": 3,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 73 will always play Team 77 in week 3
	row_data = {
		"homeTid": 73,
		"awayTid": 77,
		"conference": 8,
		"week": 3,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 75 will always play Team 79 in week 3
	row_data = {
		"homeTid": 75,
		"awayTid": 79,
		"conference": 8,
		"week": 3,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)
	
	# Team 76 will always play Team 80 in week 3
	row_data = {
		"homeTid": 76,
		"awayTid": 80,
		"conference": 8,
		"week": 3,
		"homeTeamWon": -1
	}
	database.insert_row("schedule", row_data)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	Global.week = 3
	get_tree().change_scene_to_file("res://season/practice.tscn")

func _on_button_2_pressed():
	Global.week = 3
	get_tree().change_scene_to_file("res://season/simulation.tscn")
