extends Control
var ranking = 1
var season = 2026 + Global.season
var database : SQLite
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 5, Coach " + Global.coachname + ":"
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	# Get players by pid, excluding the user's team
	database.query("""
		SELECT pid, rating
		FROM players1
		WHERE tid != %d
		ORDER BY pid ASC
		LIMIT 640 OFFSET 1920
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
	# Updating rankings
	var query = "SELECT * FROM teams1 ORDER BY wins DESC, ranking ASC"
	database.query(query)
	for i in database.query_result:
		# Assign ranking to new team starting with 1 and ending with 80
		database.update_rows("teams1", "tid == " + str(i["tid"]), {"ranking": ranking})
		# Increase ranking for next iteration
		ranking += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	Global.week = 5
	get_tree().change_scene_to_file("res://season/practice.tscn")

func _on_button_2_pressed():
	Global.week = 5
	get_tree().change_scene_to_file("res://season/simulation.tscn")

func _on_button_3_pressed():
	Global.week = 5
	get_tree().change_scene_to_file("res://season/ranking.tscn")


func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")


func _on_history_button_pressed():
	get_tree().change_scene_to_file("res://history.tscn")


func _on_achievement_button_pressed():
	get_tree().change_scene_to_file("res://achievements.tscn")
