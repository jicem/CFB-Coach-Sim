extends Control
var ranking = 1
var season = 2024 + Global.season
var database : SQLite
@onready var button = $Button
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	button.hide()
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 16, Coach " + Global.coachname + ":"
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://cfb.db"
	database.open_db()
	if Global.finalschedulecomplete == false:
		# Reset the postseason ids array
		Global.postseasonIds = []
		var homeTid
		var awayTid
		var row_data
		var rowsArray = []
		# Select the games from week 15
		var top2query = "SELECT homeTid, awayTid, homeTeamWon FROM schedule WHERE week = 15"
		database.query(top2query)
		# Fetch and store the rows
		for i in database.query_result:
			if i['homeTeamWon'] == 1:
				rowsArray.append(i["homeTid"])
				Global.postseasonIds.append(i["homeTid"])
			else:
				rowsArray.append(i["awayTid"])
				Global.postseasonIds.append(i["awayTid"])
		# Insert new rows into the schedule table for the next round
		homeTid = rowsArray[0]
		awayTid = rowsArray[1]
		row_data = {
			"homeTid": homeTid,
			"awayTid": awayTid,
			"conference": 0,
			"week": 16,
			"homeTeamWon": -1
		}
		database.insert_row("schedule", row_data)
		Global.finalschedulecomplete = true
	# Only show the practice button if the player's team is active this week
	if Global.postseasonIds.has(Global.team):
		button.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	Global.week = 16
	get_tree().change_scene_to_file("res://season/practice.tscn")

func _on_button_2_pressed():
	Global.week = 16
	get_tree().change_scene_to_file("res://season/finalsimulation.tscn")


func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")
