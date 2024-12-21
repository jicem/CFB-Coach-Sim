extends Control
var database : SQLite
@onready var timer = $Timer
@onready var prompt = %Prompt

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.season += 1
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_yes_pressed():
	# Export the table to a json-file with a specified name
	database.export_to_json("res://data/save")
	prompt.text = "Saving game and starting new season..."
	timer.start()

func _on_no_pressed():
	# Go to new game screen
	prompt.text = "Starting new season..."
	timer.start()

func _on_timer_timeout():
	get_tree().change_scene_to_file("res://newseason.tscn")
