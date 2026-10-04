extends Control
var season = 2026 + Global.season
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
	tree.set_column_title(0, "Conference")
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
	var conferenceNames = ['Elite 10 East', 'Elite 10 West', 'Big Dozen East', 'Big Dozen West',
						'South East', 'South West', 'Atlantic Coast', 'Champions',
						'National', 'Dixieland', 'Midwest', 'Great Lakes', 'Coast to Coast']
	var query = "SELECT s.homeTid, s.awayTid, s.homeTeamWon, s.conference, t1.school AS homeSchool, t2.school AS awaySchool
				FROM schedule s LEFT JOIN teams t1 ON s.homeTid = t1.tid LEFT JOIN teams t2 ON s.awayTid = t2.tid
				WHERE s.conference < 14 AND s.week = 13"
	database.query(query)
	for i in database.query_result:
		# Create variable for tree row
		treerow = tree.create_item()
		
		# Assign results from query
		var homeTeamWon = i['homeTeamWon']
		var homeSchool = i['homeSchool']
		var awaySchool = i['awaySchool']
		var c = i['conference'] - 1
		
		# Determine winning and losing teams
		var winningTeam = homeSchool if homeTeamWon == 1 else awaySchool
		var losingTeam = homeSchool if homeTeamWon == 0 else awaySchool
		
		# Add data to tree
		treerow.set_text(0, conferenceNames[c])
		treerow.set_text(1, winningTeam)
		treerow.set_text(2, losingTeam)

	# Only generate stats if the player's team has played this week
	if(hasPlayed):

		var row_data

		# Select all rows from the table with the current team ID
		var array : Array = database.select_rows(
			"players1",
			"tid == " + str(team),
			["*"]
		)

		var qb_completions = 0
		var qb_yards = 0
		var receiving_receptions = 0
		var receiving_yards = 0


		# --------------------------------
		# GET OFFENSIVE LINE RATING
		# --------------------------------

		var offensive_line = database.select_rows(
			"players1",
			"tid = " + str(team) + " AND position = 'OL'",
			["rating"]
		)

		var ol_rating = 0.0

		if offensive_line.size() > 0:
			for lineman in offensive_line:
				ol_rating += lineman["rating"]

			ol_rating /= offensive_line.size()


		# --------------------------------
		# POSITION ORDER
		# --------------------------------

		var position_order = [
			"QB",
			"WR",
			"RB",
			"TE",
			"DL",
			"LB",
			"CB",
			"S"
		]


		# --------------------------------
		# PROCESS PLAYERS
		# --------------------------------

		for desired_position in position_order:

			for row in array:

				# Skip players who aren't the current position
				if row["position"] != desired_position:
					continue

				var position = row["position"]

				# Create tree row
				treerow1 = tree2.create_item()

				# Add player information
				treerow1.set_text(0, row["firstname"])
				treerow1.set_text(1, row["lastname"])
				treerow1.set_text(2, row["position"])


				# --------------------------------
				# QB
				# --------------------------------

				if position == "QB":

					var qb_rating = row["rating"]

					# Get wide receivers
					var wide_receivers = database.select_rows(
						"players",
						"tid = " + str(team) + " AND position = 'WR'",
						["rating"]
					)

					var wr_rating = 0.0

					if wide_receivers.size() > 0:
						for receiver in wide_receivers:
							wr_rating += receiver["rating"]

						wr_rating /= wide_receivers.size()

					# QB rating determines attempts
					var attempts = randi_range(
						20 + int(qb_rating / 10.0),
						28 + int(qb_rating / 8.0)
					)

					# Offensive line determines completion percentage
					var completion_percentage = 0.45 + (ol_rating / 100.0) * 0.20
					completion_percentage += randf_range(-0.05, 0.05)
					completion_percentage = clamp(completion_percentage, 0.40, 0.70)

					var completions = int(attempts * completion_percentage)

					# WR rating influences yards per completion
					var yards_per_completion = 5.0 + (wr_rating / 10.0)
					yards_per_completion += randf_range(-1.5, 1.5)

					var yards = int(completions * yards_per_completion)
					yards = max(yards, completions * 3)

					# Save these for the receivers and tight ends
					qb_completions = completions
					qb_yards = yards

					# Insert QB stats
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

					treerow1.set_text(3, str(completions))
					treerow1.set_text(4, str(attempts))
					treerow1.set_text(5, str(yards))
					treerow1.set_text(6, "0")
					treerow1.set_text(7, "0")
					treerow1.set_text(8, "0")
					treerow1.set_text(9, "0")

				# --------------------------------
				# WR
				# --------------------------------

				elif position == "WR":

					var rating = row["rating"]

					# How many receptions are still available?
					var remaining_receptions = qb_completions - receiving_receptions

					# How many receiving yards are still available?
					var remaining_yards = qb_yards - receiving_yards

					# If there are no completions left, this receiver gets nothing
					var receptions = 0
					var yards = 0
					var targets = 0

					if remaining_receptions > 0 and remaining_yards > 0:

						# Higher-rated WRs get more receptions
						var max_receptions = 2 + int(rating / 12.0)

						max_receptions = min(
							max_receptions,
							remaining_receptions
						)

						receptions = randi_range(
							1,
							max_receptions
						)

						# Targets must be at least receptions
						var max_targets = receptions + 2 + int(rating / 24.0)

						max_targets = min(
							max_targets,
							remaining_receptions + 5
						)

						targets = randi_range(
							receptions,
							max_targets
						)

						# Rating affects yards per reception
						var yards_per_reception = 8.0 + (rating / 10.0)

						yards_per_reception += randf_range(-2.0, 2.0)

						yards = int(
							receptions * yards_per_reception
						)

						# Never exceed remaining team passing yards
						yards = min(
							yards,
							remaining_yards
						)

					# Update totals
					receiving_receptions += receptions
					receiving_yards += yards

					var tackles = 0 if randf() < 0.95 else 1

					# Insert into stats table
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
					
				# --------------------------------
				# RB
				# --------------------------------

				elif position == "RB":

					# RB's rating
					var rb_rating = row["rating"]

					# Better RBs get more rushing attempts
					var min_attempts = 8 + int(rb_rating / 15.0)
					var max_attempts = 16 + int(rb_rating / 8.0)

					# Better offensive lines increase rushing opportunities
					min_attempts += int((ol_rating - 50.0) / 25.0)
					max_attempts += int((ol_rating - 50.0) / 20.0)

					min_attempts = max(min_attempts, 5)
					max_attempts = max(max_attempts, min_attempts)

					var attempts = randi_range(
						min_attempts,
						max_attempts
					)

					# RB rating + OL rating determine yards per carry
					var yards_per_carry = 1.5

					yards_per_carry += rb_rating / 35.0
					yards_per_carry += ol_rating / 50.0

					# Add some randomness
					yards_per_carry += randf_range(-1.0, 1.0)

					yards_per_carry = max(
						yards_per_carry,
						1.0
					)

					var yards = int(
						attempts * yards_per_carry
					)

					# Completions still available from the QB
					var remaining_receptions = qb_completions - receiving_receptions

					var receptions = 0
					var targets = 0

					if remaining_receptions > 0:

						# Better RBs are more likely to receive passes
						var reception_chance = 0.05 + (rb_rating / 200.0)

						# Limit chance
						reception_chance = clamp(
							reception_chance,
							0.05,
							0.50
						)

						if randf() < reception_chance:

							var max_receptions = 1 + int(rb_rating / 35.0)

							max_receptions = min(
								max_receptions,
								remaining_receptions
							)

							receptions = randi_range(
								1,
								max_receptions
							)

							# Targets are always >= receptions
							targets = randi_range(
								receptions,
								receptions + 2
							)

					# Add RB receptions to team's total
					receiving_receptions += receptions

					var tackles = 0 if randf() < 0.9 else 1

					# --------------------------------
					# INSERT STATS
					# --------------------------------

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

					# --------------------------------
					# DISPLAY
					# --------------------------------

					treerow1.set_text(3, "0")
					treerow1.set_text(4, str(attempts))
					treerow1.set_text(5, str(yards))
					treerow1.set_text(6, str(receptions))
					treerow1.set_text(7, str(targets))
					treerow1.set_text(8, str(tackles))
					treerow1.set_text(9, "0")


				# --------------------------------
				# TE
				# --------------------------------

				elif position == "TE":

					var rating = row["rating"]

					var remaining_receptions = qb_completions - receiving_receptions
					var remaining_yards = qb_yards - receiving_yards

					var receptions = 0
					var yards = 0
					var targets = 0

					if remaining_receptions > 0 and remaining_yards > 0:

						# TEs generally receive fewer catches than WRs
						var max_receptions = 1 + int(rating / 20.0)

						max_receptions = min(
							max_receptions,
							remaining_receptions
						)

						receptions = randi_range(
							1,
							max_receptions
						)

						# Targets
						var max_targets = receptions + 2 + int(rating / 30.0)

						targets = randi_range(
							receptions,
							max_targets
						)

						targets = min(
							targets,
							qb_completions
						)

						# Rating determines yards per reception
						var yards_per_reception = 6.0 + (rating / 12.0)

						yards_per_reception += randf_range(-1.5, 1.5)

						yards = int(
							receptions * yards_per_reception
						)

						# Never exceed remaining passing yards
						yards = min(
							yards,
							remaining_yards
						)

					# Update team totals
					receiving_receptions += receptions
					receiving_yards += yards

					var tackles = 0 if randf() < 0.80 else 1

					# Insert into stats table
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


				# --------------------------------
				# DL
				# --------------------------------

				elif position == "DL":

					var dl_rating = row["rating"]

					# --------------------------------
					# TACKLES
					# --------------------------------

					# Higher-rated DL get slightly more tackles
					var min_tackles = 1 + int(dl_rating / 30.0)
					var max_tackles = 3 + int(dl_rating / 15.0)

					# Keep tackle totals reasonable
					min_tackles = clamp(min_tackles, 1, 4)
					max_tackles = clamp(max_tackles, min_tackles, 7)

					var tackles = randi_range(
						min_tackles,
						max_tackles
					)

					# --------------------------------
					# SACKS
					# --------------------------------

					# Rating determines probability of a sack
					var sack_chance = 0.03 + (dl_rating / 1000.0)

					sack_chance = clamp(
						sack_chance,
						0.03,
						0.15
					)

					var sacks = 0

					if randf() < sack_chance:
						sacks = 1

					# Small chance of a second sack for elite DL
					if dl_rating >= 85 and randf() < 0.05:
						sacks += 1

					# --------------------------------
					# INSERT INTO STATS TABLE
					# --------------------------------

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

					# --------------------------------
					# DISPLAY
					# --------------------------------

					treerow1.set_text(3, "0")
					treerow1.set_text(4, "0")
					treerow1.set_text(5, "0")
					treerow1.set_text(6, "0")
					treerow1.set_text(7, "0")
					treerow1.set_text(8, str(tackles))
					treerow1.set_text(9, str(sacks))


				# --------------------------------
				# LB
				# --------------------------------

				elif position == "LB":

					var lb_rating = row["rating"]

					# --------------------------------
					# TACKLES
					# --------------------------------

					# Higher-rated LBs get more tackles
					var min_tackles = 2 + int(lb_rating / 30.0)
					var max_tackles = 4 + int(lb_rating / 12.0)

					# Keep tackle totals reasonable
					min_tackles = clamp(min_tackles, 2, 5)
					max_tackles = clamp(max_tackles, min_tackles, 10)

					var tackles = randi_range(
						min_tackles,
						max_tackles
					)

					# --------------------------------
					# SACKS
					# --------------------------------

					# Higher-rated LBs are more likely to record a sack
					var sack_chance = 0.04 + (lb_rating / 800.0)

					sack_chance = clamp(
						sack_chance,
						0.04,
						0.16
					)

					var sacks = 0

					if randf() < sack_chance:
						sacks = 1

					# Small chance of multiple sacks for elite LBs
					if lb_rating >= 85 and randf() < 0.05:
						sacks += 1

					# --------------------------------
					# INSERT INTO STATS TABLE
					# --------------------------------

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

					# --------------------------------
					# DISPLAY
					# --------------------------------

					treerow1.set_text(3, "0")
					treerow1.set_text(4, "0")
					treerow1.set_text(5, "0")
					treerow1.set_text(6, "0")
					treerow1.set_text(7, "0")
					treerow1.set_text(8, str(tackles))
					treerow1.set_text(9, str(sacks))


				# --------------------------------
				# CB
				# --------------------------------

				elif position == "CB":

					var cb_rating = row["rating"]

					# --------------------------------
					# TACKLES
					# --------------------------------

					# Higher-rated CBs get slightly more tackles
					var min_tackles = 1 + int(cb_rating / 35.0)
					var max_tackles = 3 + int(cb_rating / 18.0)

					# Keep tackle totals reasonable
					min_tackles = clamp(min_tackles, 1, 4)
					max_tackles = clamp(max_tackles, min_tackles, 7)

					var tackles = randi_range(
						min_tackles,
						max_tackles
					)

					# --------------------------------
					# INSERT INTO STATS TABLE
					# --------------------------------

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

					# --------------------------------
					# DISPLAY
					# --------------------------------

					treerow1.set_text(3, "0")
					treerow1.set_text(4, "0")
					treerow1.set_text(5, "0")
					treerow1.set_text(6, "0")
					treerow1.set_text(7, "0")
					treerow1.set_text(8, str(tackles))
					treerow1.set_text(9, "0")


				# --------------------------------
				# S
				# --------------------------------

				elif position == "S":

					var s_rating = row["rating"]

					# --------------------------------
					# TACKLES
					# --------------------------------

					# Higher-rated safeties get slightly more tackles
					var min_tackles = 1 + int(s_rating / 30.0)
					var max_tackles = 3 + int(s_rating / 15.0)

					# Keep tackle totals reasonable
					min_tackles = clamp(min_tackles, 1, 4)
					max_tackles = clamp(max_tackles, min_tackles, 8)

					var tackles = randi_range(
						min_tackles,
						max_tackles
					)

					# --------------------------------
					# INSERT INTO STATS TABLE
					# --------------------------------

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

					# --------------------------------
					# DISPLAY
					# --------------------------------

					treerow1.set_text(3, "0")
					treerow1.set_text(4, "0")
					treerow1.set_text(5, "0")
					treerow1.set_text(6, "0")
					treerow1.set_text(7, "0")
					treerow1.set_text(8, str(tackles))
					treerow1.set_text(9, "0")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	get_tree().change_scene_to_file("res://season/week14.tscn")

func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")


func _on_history_button_pressed():
	get_tree().change_scene_to_file("res://history.tscn")


func _on_achievement_button_pressed():
	get_tree().change_scene_to_file("res://achievements.tscn")
