extends Control
var season = 2024 + Global.season
var team = Global.team
var week = Global.week
var nextWeek = week + 1
var hasPlayed = false
var database : SQLite
var score : String
var treerow : TreeItem
var treerow1 : TreeItem
@onready var tree = $Tree
@onready var tree2 = $Tree2
@onready var label = %Label
@onready var label2 = %Label2
@onready var label3 = %Label3
@onready var label4 = %Label4
@onready var button = $Button

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.state += 1
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	# Add column names for tree
	tree.set_column_title(0, "Game")
	tree.set_column_title(1, "Winning Team")
	tree.set_column_title(2, "Losing Team")
	# The root node is hidden in the tree
	treerow = tree.create_item()
	treerow.set_text(0, "Hidden")
	treerow.set_text(1, "Hidden")
	treerow.set_text(2, "Hidden")
	# Add column names for second tree2
	tree2.set_column_title(0, "First Name")
	tree2.set_column_title(1, "Last Name")
	tree2.set_column_title(2, "Position")
	tree2.set_column_title(3, "Completions")
	tree2.set_column_title(4, "Attempts")
	tree2.set_column_title(5, "Yards")
	tree2.set_column_title(6, "Receptions")
	tree2.set_column_title(7, "Targets")
	tree2.set_column_title(8, "Tackles")
	tree2.set_column_title(9, "Sacks")
	# The root node is hidden in the tree2
	treerow1 = tree2.create_item()
	for i in range(10):
		treerow1.set_text(i, "Hidden")
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
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
			query = "SELECT SUM(rating) AS total_ratings FROM players1 WHERE tid = " + str(homeTid)
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
			query = "SELECT SUM(rating) AS total_ratings FROM players1 WHERE tid = " + str(awayTid)
			database.query(query)
			for i in database.query_result:
				if awayTid == team:
					query = "SELECT ocid FROM teams1 WHERE tid = " + str(awayTid)
					database.query(query)
					for j in database.query_result:
						oc = j["ocid"]
					query = "SELECT dcid FROM teams1 WHERE tid = " + str(awayTid)
					database.query(query)
					for j in database.query_result:
						dc = j["dcid"]
					# If the player's team doesn't have an offensive or defensive coordinator, simply do the player ratings
					if oc == 0 and dc == 0:
						away_result = i["total_ratings"]
					# If the player's team only has an offensive coordinator, add his rating to the result
					elif oc != 0 and dc == 0:
						query = "SELECT rating, scheme FROM offcoordinators WHERE ocid = " + str(oc)
						database.query(query)
						for j in database.query_result:
							# If the scheme for the coordinator and head coach are the same, double the rating
							if j["scheme"] == Global.offense:
								# Query to add the ratings of the offensive and defensive coordinators
								var newRating = j["rating"] * 2
								away_result = i["total_ratings"] + newRating
							# If the scheme for the coordinator and head coach are not the same, use the normal rating
							else:
								away_result = i["total_ratings"] + j["rating"]
					# If the player's team only has a defensive coordinator, add his rating to the result
					elif oc == 0 and dc != 0:
						query = "SELECT rating, scheme FROM defcoordinators WHERE dcid = " + str(dc)
						database.query(query)
						for j in database.query_result:
							# If the scheme for the coordinator and head coach are the same, double the rating
							if j["scheme"] == Global.defense:
								var newRating = j["rating"] * 2
								away_result = i["total_ratings"] + newRating
							# If the scheme for the coordinator and head coach are not the same, use the normal rating
							else:
								away_result = i["total_ratings"] + j["rating"]
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
												JOIN defcoordinators d ON d.dcid = t.dcid WHERE t.tid = " + str(awayTid)
										database.query(query)
										for l in database.query_result:
											away_result = i["total_ratings"] + l["coord_ratings"]
									else:
										# If only the offensive coordinator's scheme is equal to the player's, double one rating
										query = "SELECT (o.rating * 2) + d.rating AS coord_ratings FROM teams1 t
												JOIN offcoordinators o ON o.ocid = t.ocid
												JOIN defcoordinators d ON d.dcid = t.dcid WHERE t.tid = " + str(awayTid)
										database.query(query)
										for l in database.query_result:
											away_result = i["total_ratings"] + l["coord_ratings"]
							else:
								query = "SELECT scheme FROM defcoordinators WHERE dcid = " + str(dc)
								database.query(query)
								for k in database.query_result:
									if k["scheme"] == Global.defense:
										# If only the defensive coordinator's scheme is equal to the player's, double one rating
										query = "SELECT o.rating + (d.rating * 2) AS coord_ratings FROM teams1 t
												JOIN offcoordinators o ON o.ocid = t.ocid
												JOIN defcoordinators d ON d.dcid = t.dcid WHERE t.tid = " + str(awayTid)
										database.query(query)
										for l in database.query_result:
											away_result = i["total_ratings"] + l["coord_ratings"]
									else:
										# If neither scheme is equal to the player's, add the normal ratings
										query = "SELECT (o.rating + d.rating) AS coord_ratings FROM teams1 t
												JOIN offcoordinators o ON o.ocid = t.ocid
												JOIN defcoordinators d ON d.dcid = t.dcid WHERE t.tid = " + str(awayTid)
										database.query(query)
										for l in database.query_result:
											away_result = i["total_ratings"] + l["coord_ratings"]
				else:
					# Query to add the ratings of the offensive and defensive coordinators
					query = "SELECT (o.rating + d.rating) AS coord_ratings FROM teams1 t JOIN offcoordinators o ON o.ocid = t.ocid
							JOIN defcoordinators d ON d.dcid = t.dcid WHERE t.tid = " + str(awayTid)
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
				hasPlayed = true
				# Calculate the difference between home and away sums
				var score_difference = abs(home_result - away_result)
				var score_query
				# Select a random score based on the score difference
				if score_difference > 400:
					score_query = "SELECT blowout FROM scores ORDER BY RANDOM() LIMIT 1"
					database.query(score_query)
					for i in database.query_result:
						score = i["blowout"]
				elif score_difference >= 100 && score_difference <= 400:
					score_query = "SELECT normal FROM scores ORDER BY RANDOM() LIMIT 1"
					database.query(score_query)
					for i in database.query_result:
						score = i["normal"]
				else:
					score_query = "SELECT close FROM scores ORDER BY RANDOM() LIMIT 1"
					database.query(score_query)
					for i in database.query_result:
						score = i["close"]
				# Variables for displaying the result and other useful info
				var opponent
				var oppRanking
				var ranking
				# If the coach's team is the home team, display the appropriate result
				if homeTid == team:
					var array2 : Array = database.select_rows("teams1", "tid == " + str(awayTid), ["*"])
					for newRow in array2:
						opponent = newRow["school"]
						oppRanking = newRow["ranking"]
						if oppRanking > 0 and oppRanking < 26:
							ranking = "#" + str(oppRanking) + " "
						else: ranking = ""
					if team_won == 1:
						label2.text = "Coach " + Global.coachname + ", your team defeated"
					else:
						label2.text = "Coach " + Global.coachname + ", your team was defeated by"
				# If the coach's team is the away team, display the appropriate result
				else:
					var array2 : Array = database.select_rows("teams1", "tid == " + str(homeTid), ["*"])
					for newRow in array2:
						opponent = newRow["school"]
						oppRanking = newRow["ranking"]
						if oppRanking > 0 and oppRanking < 26:
							ranking = "#" + str(oppRanking) + " "
						else: ranking = ""
					if team_won == 1:
						label2.text = "Coach " + Global.coachname + ", your team was defeated by"
					else:
						label2.text = "Coach " + Global.coachname + ", your team defeated"
				label3.text = ranking + opponent + " by a score of " + score
	if hasPlayed == false:
		label2.text = "Coach " + Global.coachname + ", your team didn't play this week."
		label3.text = ""
		
	# Define conference names
	var query = "SELECT s.homeTid, s.awayTid, s.homeTeamWon, t1.school AS homeSchool, t2.school AS awaySchool FROM schedule s
				LEFT JOIN teams t1 ON s.homeTid = t1.tid LEFT JOIN teams t2 ON s.awayTid = t2.tid WHERE s.week = 15"
	database.query(query)
	for i in database.query_result:
		# Create variable for tree row
		treerow = tree.create_item()
		
		# Assign results from query
		var homeTeamWon = i['homeTeamWon']
		var homeSchool = i['homeSchool']
		var awaySchool = i['awaySchool']
		
		# Determine winning and losing teams
		var winningTeam = homeSchool if homeTeamWon == 1 else awaySchool
		var losingTeam = homeSchool if homeTeamWon == 0 else awaySchool
		
		# Add data to tree
		treerow.set_text(0, "Semifinal")
		treerow.set_text(1, winningTeam)
		treerow.set_text(2, losingTeam)
		
	var row_data
	# Select all rows from the table with the current team ID
	var array : Array = database.select_rows("players", "tid == " + str(team), ["*"])
	for row in array:
		var position = row["position"]
		if(position == "OL"): continue
		elif(position == "K"): continue
		else:
			# Create variable for tree row
			treerow1 = tree2.create_item()
			# Add data to tree
			treerow1.set_text(0, row["firstname"])
			treerow1.set_text(1, row["lastname"])
			treerow1.set_text(2, row["position"])
			
			# Only generate stats if the player's team has played this week
			if(hasPlayed):
				# Filling rows for each position
				if(position == "QB"):
					
					# Generate random numbers for pass attempts, pass completions, and yards
					var completions = randi_range(19, 27)
					var attempts = randi_range(completions, 41)
					var yards = randi_range(150, 400)
					
					# Insert into the stats table
					row_data = {
						"sid": Global.season,
						"pid": row["pid"],
						"completions": completions,
						"attempts": attempts,
						"yards": yards,
						"receptions": 0,
						"targets": 0,
						"tackles": 0,
						"sacks": 0
					}
					database.insert_row("player_stats", row_data)
					
					# Print out the generated numbers
					print("Pass Completions:", completions)
					print("Pass Attempts:", attempts)
					print("Yards Gained:", yards)
					
					# Add to table
					treerow1.set_text(3, str(completions))
					treerow1.set_text(4, str(attempts))
					treerow1.set_text(5, str(yards))
					treerow1.set_text(6, "0")
					treerow1.set_text(7, "0")
					treerow1.set_text(8, "0")
					treerow1.set_text(9, "0")
					
				if(position == "WR"):
					
					# Generate random numbers
					var yards = randi_range(36, 80)
					var receptions = randi_range(2, 6)
					var targets = randi_range(receptions, 8)
					var tackles = 0 if randf() < 0.95 else 1
					
					# Insert into the stats table
					row_data = {
						"sid": Global.season,
						"pid": row["pid"],
						"completions": 0,
						"attempts": 0,
						"yards": yards,
						"receptions": receptions,
						"targets": targets,
						"tackles": tackles,
						"sacks": 0
					}
					database.insert_row("player_stats", row_data)
					
					# Add to table
					treerow1.set_text(3, "0")
					treerow1.set_text(4, "0")
					treerow1.set_text(5, str(yards))
					treerow1.set_text(6, str(receptions))
					treerow1.set_text(7, str(targets))
					treerow1.set_text(8, str(tackles))
					treerow1.set_text(9, "0")
					
				if(position == "RB"):
					
					# Generate random numbers
					var attempts = randi_range(10, 25)
					var yards = randi_range(40, 200)
					var receptions = randi_range(0, 2)
					var targets = randi_range(receptions, 3)
					var tackles = 0 if randf() < 0.9 else 1
					
					# Insert into the stats table
					row_data = {
						"sid": Global.season,
						"pid": row["pid"],
						"completions": 0,
						"attempts": attempts,
						"yards": yards,
						"receptions": receptions,
						"targets": targets,
						"tackles": tackles,
						"sacks": 0
					}
					database.insert_row("player_stats", row_data)
					
					# Add to table
					treerow1.set_text(3, "0")
					treerow1.set_text(4, str(attempts))
					treerow1.set_text(5, str(yards))
					treerow1.set_text(6, str(receptions))
					treerow1.set_text(7, str(targets))
					treerow1.set_text(8, str(tackles))
					treerow1.set_text(9, "0")
					
				if(position == "TE"):
					
					# Generate random numbers
					var yards = randi_range(18, 40)
					var receptions = randi_range(1, 3)
					var targets = randi_range(receptions, 5)
					var tackles = 0 if randf() < 0.8 else 1
					
					# Insert into the stats table
					row_data = {
						"sid": Global.season,
						"pid": row["pid"],
						"completions": 0,
						"attempts": 0,
						"yards": yards,
						"receptions": receptions,
						"targets": targets,
						"tackles": tackles,
						"sacks": 0
					}
					database.insert_row("player_stats", row_data)
					
					# Add to table
					treerow1.set_text(3, "0")
					treerow1.set_text(4, "0")
					treerow1.set_text(5, str(yards))
					treerow1.set_text(6, str(receptions))
					treerow1.set_text(7, str(targets))
					treerow1.set_text(8, str(tackles))
					treerow1.set_text(9, "0")
					
				if(position == "DL"):
					
					# Generate random numbers
					var tackles = randi_range(1, 5)
					var sacks = 0 if randf() < 0.9 else 1
					
					# Insert into the stats table
					row_data = {
						"sid": Global.season,
						"pid": row["pid"],
						"completions": 0,
						"attempts": 0,
						"yards": 0,
						"receptions": 0,
						"targets": 0,
						"tackles": tackles,
						"sacks": sacks
					}
					database.insert_row("player_stats", row_data)
					
					# Add to table
					treerow1.set_text(3, "0")
					treerow1.set_text(4, "0")
					treerow1.set_text(5, "0")
					treerow1.set_text(6, "0")
					treerow1.set_text(7, "0")
					treerow1.set_text(8, str(tackles))
					treerow1.set_text(9, str(sacks))
					
				if(position == "LB"):
					
					# Generate random numbers
					var tackles = randi_range(1, 6)
					var sacks = 0 if randf() < 0.9 else 1
					
					# Insert into the stats table
					row_data = {
						"sid": Global.season,
						"pid": row["pid"],
						"completions": 0,
						"attempts": 0,
						"yards": 0,
						"receptions": 0,
						"targets": 0,
						"tackles": tackles,
						"sacks": sacks
					}
					database.insert_row("player_stats", row_data)
					
					# Add to table
					treerow1.set_text(3, "0")
					treerow1.set_text(4, "0")
					treerow1.set_text(5, "0")
					treerow1.set_text(6, "0")
					treerow1.set_text(7, "0")
					treerow1.set_text(8, str(tackles))
					treerow1.set_text(9, str(sacks))

				if(position == "CB"):
					
					# Generate random numbers
					var tackles = randi_range(1, 5)
					var sacks = 0 if randf() < 0.95 else 1
					
					# Insert into the stats table
					row_data = {
						"sid": Global.season,
						"pid": row["pid"],
						"completions": 0,
						"attempts": 0,
						"yards": 0,
						"receptions": 0,
						"targets": 0,
						"tackles": tackles,
						"sacks": sacks
					}
					database.insert_row("player_stats", row_data)
					
					# Add to table
					treerow1.set_text(3, "0")
					treerow1.set_text(4, "0")
					treerow1.set_text(5, "0")
					treerow1.set_text(6, "0")
					treerow1.set_text(7, "0")
					treerow1.set_text(8, str(tackles))
					treerow1.set_text(9, str(sacks))

				if(position == "S"):
					
					# Generate random numbers
					var tackles = randi_range(1, 6)
					
					# Insert into the stats table
					row_data = {
						"sid": Global.season,
						"pid": row["pid"],
						"completions": 0,
						"attempts": 0,
						"yards": 0,
						"receptions": 0,
						"targets": 0,
						"tackles": tackles,
						"sacks": 0
					}
					database.insert_row("player_stats", row_data)
					
					# Add to table
					treerow1.set_text(3, "0")
					treerow1.set_text(4, "0")
					treerow1.set_text(5, "0")
					treerow1.set_text(6, "0")
					treerow1.set_text(7, "0")
					treerow1.set_text(8, str(tackles))
					treerow1.set_text(9, "0")
			else:
				treerow1.set_text(3, "0")
				treerow1.set_text(4, "0")
				treerow1.set_text(5, "0")
				treerow1.set_text(6, "0")
				treerow1.set_text(7, "0")
				treerow1.set_text(8, "0")
				treerow1.set_text(9, "0")
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	get_tree().change_scene_to_file("res://season/week16.tscn")

func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")


func _on_history_button_pressed():
	get_tree().change_scene_to_file("res://history.tscn")


func _on_achievement_button_pressed():
	get_tree().change_scene_to_file("res://achievements.tscn")
