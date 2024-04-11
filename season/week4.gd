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
	label2.text = "Here are your options for Week 4, Coach " + Global.coachname + ":"
	
	# If the conference schedules haven't been done yet, do them here
	if Global.schedule3complete == false:
	
		# Number of teams in each conference
		var teams = 10
		
		# Generate the (mostly) round-robin schedule
		for i in range(9):
			var conference = i + 1
			var multiple = i * 10
			for week in range(9):
				# Reset the array for the new week
				var played_teams = []
				
				# Variable for week that will be inserted into the database
				var new_week = week + 4
				
				# Check if it's the sixth week
				if week == 2:
					# The seventh team in the conference will always play the ninth team this week
					var home = 7 + multiple
					var away = 9 + multiple
					row_data = {
						"homeTid": home,
						"awayTid": away,
						"conference": conference,
						"week": 6,
						"homeTeamWon": -1
					}
					# Add the matchup to the schedule table and array
					database.insert_row("schedule", row_data)
					played_teams.append(7)
					played_teams.append(9)
					
				# Check if it's the seventh week
				if week == 3:
					# The seventh team in the conference will always play the tenth team this week
					var home = 7 + multiple
					var away = 10 + multiple
					row_data = {
						"homeTid": home,
						"awayTid": away,
						"conference": conference,
						"week": 7,
						"homeTeamWon": -1
					}
					# Add the matchup to the schedule table and array
					database.insert_row("schedule", row_data)
					played_teams.append(7)
					played_teams.append(10)
					
				# Loop through each team as the home team
				for t in range(teams):
					var team = t + 1
					
					# Skip the teams that already have matchups
					if (week == 2 and (team == 9 or team == 7)) or (week == 3 and (team == 7 or team == 10)):
						continue
					
					# Calculate the away team index
					var away_team = (team + week - 1) % (teams - 1) + 1
					
					# Adjust the away team index if it's the same as the home team
					if away_team >= team:
						away_team += 1
						
					var home = team + multiple
					var away = away_team + multiple
					
					# Check if either the home or away team has already played this week
					if !played_teams.has(team) and !played_teams.has(away_team):
						row_data = {
							"homeTid": home,
							"awayTid": away,
							"conference": conference,
							"week": new_week,
							"homeTeamWon": -1
						}
						# Add the matchup to the schedule table and array
						database.insert_row("schedule", row_data)
						played_teams.append(team)
						played_teams.append(away_team)			
						
				# Check if there are teams without matchups for the current week
				var teams_without_matchups = []
				for index in range(1, 11):
					if played_teams.has(index): continue
					else: teams_without_matchups.append(index)
				for no_matchup in teams_without_matchups:
					var home = no_matchup + multiple
					var away = randi_range(81, 100)
					# Insert the matchup into the schedule table
					row_data = {
						"homeTid": home,
						"awayTid": away,
						"conference": 0,
						"week": new_week,
						"homeTeamWon": -1
					}
					# Add the matchup to the schedule table and array
					database.insert_row("schedule", row_data)	
					
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
