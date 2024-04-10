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
	Global.state += 1
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
			var query
			var oc
			var dc
			var home_result
			var away_result
			# Query to compare sums of player ratings in the players table
			query = "SELECT SUM(rating) AS total_ratings FROM players WHERE tid = " + str(homeTid)
			database.query(query)
			for i in database.query_result:
				if homeTid == team:
					query = "SELECT ocid FROM teams1 WHERE tid = " + str(homeTid)
					database.query(query)
					for j in database.query_result:
						oc = j["ocid"]
					query = "SELECT dcid FROM teams1 WHERE tid = " + str(homeTid)
					database.query(query)
					for j in database.query_result:
						dc = j["dcid"]
					# If the player's team doesn't have an offensive or defensive coordinator, simply do the player ratings
					if oc == 0 and dc == 0:
						home_result = i["total_ratings"]
					# If the player's team only has an offensive coordinator, add his rating to the result
					elif oc != 0 and dc == 0:
						query = "SELECT rating, scheme FROM offcoordinators WHERE ocid = " + str(oc)
						database.query(query)
						for j in database.query_result:
							# If the scheme for the coordinator and head coach are the same, double the rating
							if j["scheme"] == Global.offense:
								# Query to add the ratings of the offensive and defensive coordinators
								var newRating = j["rating"] * 2
								home_result = i["total_ratings"] + newRating
							# If the scheme for the coordinator and head coach are not the same, use the normal rating
							else:
								home_result = i["total_ratings"] + j["rating"]
					# If the player's team only has a defensive coordinator, add his rating to the result
					elif oc == 0 and dc != 0:
						query = "SELECT rating, scheme FROM defcoordinators WHERE dcid = " + str(dc)
						database.query(query)
						for j in database.query_result:
							# If the scheme for the coordinator and head coach are the same, double the rating
							if j["scheme"] == Global.defense:
								var newRating = j["rating"] * 2
								home_result = i["total_ratings"] + newRating
							# If the scheme for the coordinator and head coach are not the same, use the normal rating
							else:
								home_result = i["total_ratings"] + j["rating"]
					# If the player's team has both coordinators, add both ratings to tne result
					else:
						query = "SELECT scheme FROM offcoordinators WHERE ocid = " + str(oc)
						database.query(query)
						for j in database.query_result:
							if j["scheme"] == Global.offense:
								query = "SELECT scheme FROM defcoordinators WHERE dcid = " + str(dc)
								database.query(query)
								for k in database.query_result:
									if k["scheme"] == Global.defense:
										# If both schemes are equal to the player's schemes, both ratings will be doubled
										query = "SELECT (o.rating + d.rating) * 2 AS coord_ratings FROM teams1 t
												JOIN offcoordinators o ON o.ocid = t.ocid
												JOIN defcoordinators d ON d.dcid = t.dcid WHERE t.tid = " + str(homeTid)
										database.query(query)
										for l in database.query_result:
											home_result = i["total_ratings"] + l["coord_ratings"]
									else:
										# If only the offensive coordinator's scheme is equal to the player's, double one rating
										query = "SELECT (o.rating * 2) + d.rating AS coord_ratings FROM teams1 t
												JOIN offcoordinators o ON o.ocid = t.ocid
												JOIN defcoordinators d ON d.dcid = t.dcid WHERE t.tid = " + str(homeTid)
										database.query(query)
										for l in database.query_result:
											home_result = i["total_ratings"] + l["coord_ratings"]
							else:
								query = "SELECT scheme FROM defcoordinators WHERE dcid = " + str(dc)
								database.query(query)
								for k in database.query_result:
									if k["scheme"] == Global.defense:
										# If only the defensive coordinator's scheme is equal to the player's, double one rating
										query = "SELECT o.rating + (d.rating * 2) AS coord_ratings FROM teams1 t
												JOIN offcoordinators o ON o.ocid = t.ocid
												JOIN defcoordinators d ON d.dcid = t.dcid WHERE t.tid = " + str(homeTid)
										database.query(query)
										for l in database.query_result:
											home_result = i["total_ratings"] + l["coord_ratings"]
									else:
										# If neither scheme is equal to the player's, add the normal ratings
										query = "SELECT (o.rating + d.rating) AS coord_ratings FROM teams1 t
												JOIN offcoordinators o ON o.ocid = t.ocid
												JOIN defcoordinators d ON d.dcid = t.dcid WHERE t.tid = " + str(homeTid)
										database.query(query)
										for l in database.query_result:
											home_result = i["total_ratings"] + l["coord_ratings"]
				else:
					# Query to add the ratings of the offensive and defensive coordinators
					query = "SELECT (o.rating + d.rating) AS coord_ratings FROM teams1 t
							JOIN offcoordinators o ON o.ocid = t.ocid
							JOIN defcoordinators d ON d.dcid = t.dcid WHERE t.tid = " + str(homeTid)
					database.query(query)
					for j in database.query_result:
						home_result = i["total_ratings"] + j["coord_ratings"]
			query = "SELECT SUM(rating) AS total_ratings FROM players WHERE tid = " + str(awayTid)
			database.query(query)
			for i in database.query_result:
				if awayTid == team:
					pass
				else:
					# Query to add the ratings of the offensive and defensive coordinators
					query = "SELECT (o.rating + d.rating) AS coord_ratings FROM teams1 t JOIN offcoordinators o ON o.ocid = t.ocid
							JOIN defcoordinators d ON d.dcid = t.dcid WHERE t.tid = " + str(homeTid)
					database.query(query)
					for j in database.query_result:
						away_result = i["total_ratings"] + j["coord_ratings"]
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
	elif nextWeek == 5:
		get_tree().change_scene_to_file("res://season/week5.tscn")
	elif nextWeek == 6:
		get_tree().change_scene_to_file("res://season/week6.tscn")
	elif nextWeek == 7:
		get_tree().change_scene_to_file("res://season/week7.tscn")

func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")
