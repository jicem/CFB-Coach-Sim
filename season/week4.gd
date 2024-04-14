extends Control
var database : SQLite
var season = 2024 + Global.season
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	var row_data
	
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://cfb.db"
	database.open_db()
	
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 4, Coach " + Global.coachname + ":"
	
	# If the conference schedules haven't been done yet, do them here
	if Global.schedule3complete == false:
	
		# Number of teams in each conference
		var teams = 10
		
		# Array to store matchups for each conference
		var matchups = []
		
		# Generate the round-robin schedule
		for i in range(8):
			var conferenceMatchups = []
			var conference = i + 1
			var multiple = i * 10
			for week in range(teams - 1):
				# Variable for week that will be inserted into the database
				var new_week = week + 4
				var weekMatchup = []
				for j in range(teams / 2):
					var team1 = (week + j) % (teams - 1) + 1
					var team2 = (teams - 1 - j + week) % (teams - 1) + 1
					if j == 0:
						team2 = teams
					weekMatchup.append(team1)
					weekMatchup.append(team2)
					# Insert the row into the schedule table
					row_data = {
						"homeTid": team1 + multiple,
						"awayTid": team2 + multiple,
						"conference": conference,
						"week": new_week,
						"homeTeamWon": -1
					}
					database.insert_row("schedule", row_data)
				conferenceMatchups.append(weekMatchup)
			matchups.append(conferenceMatchups)
			
			# Printing matchups to ensure that they're correct
			print("Matchups for conference " + str(i + 1) + ": ")
			print(matchups[i])
		Global.schedule3complete = true
					
	else: pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	Global.week = 4
	get_tree().change_scene_to_file("res://season/practice.tscn")
	
func _on_button_2_pressed():
	Global.week = 4
	get_tree().change_scene_to_file("res://season/simulation.tscn")


func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")
