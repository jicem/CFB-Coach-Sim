extends Control
var database : SQLite
var season = 2026 + Global.season
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	var row_data
	
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 3, Coach " + Global.coachname + ":"

	# Get players by pid, excluding the user's team
	database.query("""
		SELECT pid, rating
		FROM players1
		WHERE tid != %d
		ORDER BY pid ASC
		LIMIT 640 OFFSET 640
	""" % Global.team)

	var other_players : Array = database.query_result

	# Increase every selected player's rating by 1
	for row in other_players:
		var rating = int(row["rating"])

		if rating < 99:
			rating += 1

			database.update_rows(
				"players1",
				"pid == " + str(row["pid"]),
				{"rating": rating}
			)

	# If the week 3 schedule hasn't been done yet, do it here
	if Global.schedule2complete == false:

		# Create an array of teams 71-140
		var available_ids = []

		for i in range(71, 141):
			available_ids.append(i)

		# Create 70 Week 2 games
		for i in range(70):

			var home_tid = i + 1
			var away_tid = -1

			# Find this team's Week 2 opponent
			var week2_opponent = -1

			var week2_query = """
				SELECT homeTid, awayTid
				FROM schedule
				WHERE week = 2
				AND (homeTid = %d OR awayTid = %d)
			""" % [home_tid, home_tid]

			database.query(week2_query)

			for game in database.query_result:
				if game["homeTid"] == home_tid:
					week2_opponent = game["awayTid"]
				else:
					week2_opponent = game["homeTid"]

			# Find a random opponent that wasn't the Week 1 opponent
			var valid_opponent = false

			while not valid_opponent:

				var random_index = randi() % available_ids.size()
				var potential_opponent = available_ids[random_index]

				if potential_opponent != week2_opponent:
					away_tid = potential_opponent
					valid_opponent = true

			# Remove the opponent so they can't be scheduled again
			available_ids.erase(away_tid)

			# Insert Week 2 matchup
			row_data = {
				"homeTid": home_tid,
				"awayTid": away_tid,
				"conference": 0,
				"week": 3,
				"homeTeamWon": -1
			}

			database.insert_row("schedule", row_data)

		Global.schedule2complete = true
		
	else: pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	Global.week = 3
	get_tree().change_scene_to_file("res://season/practice.tscn")

func _on_button_2_pressed():
	Global.week = 3
	get_tree().change_scene_to_file("res://season/simulation.tscn")


func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")


func _on_history_button_pressed():
	get_tree().change_scene_to_file("res://history.tscn")


func _on_achievement_button_pressed():
	get_tree().change_scene_to_file("res://achievements.tscn")
