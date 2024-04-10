extends Control
var ranking = 1
var season = 2024 + Global.season
var database : SQLite
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	# Display the current season at the top of the screen
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 7, Coach " + Global.coachname + ":"
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://cfb.db"
	database.open_db()
	# Updating rankings
	var query = "SELECT * FROM teams1 ORDER BY wins DESC, ranking ASC LIMIT 80"
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
	Global.week = 7
	get_tree().change_scene_to_file("res://season/practice.tscn")

func _on_button_2_pressed():
	Global.week = 7
	get_tree().change_scene_to_file("res://season/simulation.tscn")

func _on_button_3_pressed():
	Global.week = 7
	get_tree().change_scene_to_file("res://season/ranking.tscn")


func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")
