extends Control
var database : SQLite
var season = 2024 + Global.season
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	var available_ids
	var row_data
	
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://cfb.db"
	database.open_db()
	
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 2, Coach " + Global.coachname + ":"
	
	# If the week 2 schedule hasn't been done yet, do it here
	if Global.schedule1complete == false:
		
		# Create an array of numbers between 21 and 40
		available_ids = []
		for i in range(21, 41):
			available_ids.append(i)

		# Create a loop that inserts a new row into the schedule table 20 times
		for i in range(20):
			
			# Get the homeTid
			var home_tid = i + 1
			
			# Select a random index from the available_ids array
			var random_index = randi() % available_ids.size()
			
			# Get the awayTid from the current index
			var away_tid = available_ids[random_index]
			
			# Remove the used value from the array
			available_ids.remove_at(random_index)

			# Insert the row into the schedule table
			row_data = {
				"homeTid": home_tid,
				"awayTid": away_tid,
				"conference": 0,
				"week": 2,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
		# Create an array of numbers between 61 and 80
		available_ids = []
		for i in range(61, 81):
			available_ids.append(i)

		# Create a loop that inserts a new row into the schedule table 20 times
		for i in range(41, 61):
			
			# Get the homeTid
			var home_tid = i
			
			# Select a random index from the available_ids array
			var random_index = randi() % available_ids.size()
			
			# Get the awayTid from the current index
			var away_tid = available_ids[random_index]
			
			# Remove the used value from the array
			available_ids.remove_at(random_index)

			# Insert the row into the schedule table
			row_data = {
				"homeTid": home_tid,
				"awayTid": away_tid,
				"conference": 0,
				"week": 2,
				"homeTeamWon": -1
			}
			database.insert_row("schedule", row_data)
		
		Global.schedule1complete = true
		
	else: pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_2_pressed():
	Global.week = 2
	get_tree().change_scene_to_file("res://season/simulation.tscn")


func _on_button_pressed():
	Global.week = 2
	get_tree().change_scene_to_file("res://season/practice.tscn")


func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")
