extends Control
var season = 2024 + Global.season
var team = Global.team
var week = Global.week
var nextWeek = week + 1
var database : SQLite
var score : String
@onready var label = %Label
@onready var label2 = %Label2
@onready var label3 = %Label3
@onready var label4 = %Label4
@onready var button = $Button

# Called when the node enters the scene tree for the first time.
func _ready():
	var wins
	var losses
	# Display the current season at the top of the screen and display next week's number in the button
	label.text = str(season) + " Season"
	button.text = "Sim to Week " + str(nextWeek)
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://cfb.db"
	database.open_db()
	# Initialize score variable
	score = "0-0"
	# Retrieve schedule info
	var array1 : Array = database.select_rows("schedule", "week == " + str(week), ["*"])
	for row in array1:
		var homeTid = row["homeTid"]
		var awayTid = row["awayTid"]
		var gid = row["gid"]
		var homeTeamWonForRow = row["homeTeamWon"]
		if(homeTeamWonForRow < 0):
			var home_result
			var away_result
			# Query to compare sums of player ratings in the players table
			var query = "SELECT SUM(rating) AS total_ratings FROM players WHERE tid = " + str(homeTid)
			database.query(query)
			for i in database.query_result:
				home_result = i["total_ratings"]
			query = "SELECT SUM(rating) AS total_ratings FROM players WHERE tid = " + str(awayTid)
			database.query(query)
			for i in database.query_result:
				away_result = i["total_ratings"]
			var team_won
			# Update wins and losses in the teams1 table based on the result
			if home_result > away_result:
				team_won = 1
				query = "UPDATE teams1 SET wins = wins + 1 WHERE tid = " + str(homeTid)
				database.query(query)
				query = "UPDATE teams1 SET losses = losses + 1 WHERE tid = " + str(awayTid)
				database.query(query)
				print("Team " + str(homeTid) + " won")
			else:
				team_won = 0
				query = "UPDATE teams1 SET wins = wins + 1 WHERE tid = " + str(awayTid)
				database.query(query)
				query = "UPDATE teams1 SET losses = losses + 1 WHERE tid = " + str(homeTid)
				database.query(query)
				print("Team " + str(awayTid) + " won")
			# Update homeTeamWon in the schedule table
			database.update_rows("schedule", "gid == " + str(gid), {"homeTeamWon": team_won})
			# Display the result message based on whether the coach's team played
			if homeTid == team || awayTid == team:
				# Calculate the difference between home and away sums
				var score_difference = abs(home_result - away_result)
				var score_query
				var score
				# Select a random score based on the score difference
				if score_difference > 400:
					score_query = "SELECT Score FROM blowoutscores ORDER BY RANDOM() LIMIT 1"
				elif score_difference >= 100 && score_difference <= 400:
					score_query = "SELECT Score FROM normalscores ORDER BY RANDOM() LIMIT 1"
				else:
					score_query = "SELECT Score FROM closescores ORDER BY RANDOM() LIMIT 1"
				database.query(score_query)
				for i in database.query_result:
					score = i["Score"]
				# Variables for displaying the result and other useful info
				var opponent
				var oppRanking
				var school
				var ranking
				# If the coach's team is the home team, display the appropriate result
				if homeTid == team:
					var array2 : Array = database.select_rows("teams1", "tid == " + str(awayTid), ["*"])
					for newRow in array2:
						opponent = newRow["school"]
						oppRanking = newRow["ranking"]
						if newRow["ranking"] > 0 and newRow["ranking"] < 26:
							ranking = "#" + str(oppRanking) + " "
						else: ranking = ""
					if team_won == 1:
						label2.text = "Coach " + Global.coachname + ", your team defeated"
					else:
						label2.text = "Coach " + Global.coachname + ", your team was defeated by"
					var array3 : Array = database.select_rows("teams1", "tid == " + str(homeTid), ["*"])
					for newRow in array3:
						school = newRow["school"]
						wins = newRow["wins"]
						losses = newRow["losses"]
				# If the coach's team is the away team, display the appropriate result
				else:
					var array2 : Array = database.select_rows("teams1", "tid == " + str(homeTid), ["*"])
					for newRow in array2:
						opponent = newRow["school"]
						oppRanking = newRow["ranking"]
						if newRow["ranking"] > 0 and newRow["ranking"] < 26:
							ranking = "#" + str(oppRanking) + " "
						else: ranking = ""
					if team_won == 1:
						label2.text = "Coach " + Global.coachname + ", your team was defeated by"
					else:
						label2.text = "Coach " + Global.coachname + ", your team defeated"
					var array3 : Array = database.select_rows("teams1", "tid == " + str(awayTid), ["*"])
					for newRow in array3:
						school = newRow["school"]
						wins = newRow["wins"]
						losses = newRow["losses"]
				label3.text = ranking + opponent + " by a score of " + score
				label4.text = school + " Record: " + str(wins) + "-" + str(losses)
				

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	if nextWeek == 2:
		get_tree().change_scene_to_file("res://season/week2.tscn")
	elif nextWeek == 3:
		get_tree().change_scene_to_file("res://season/week3.tscn")
	elif nextWeek == 4:
		get_tree().change_scene_to_file("res://season/week4.tscn")
