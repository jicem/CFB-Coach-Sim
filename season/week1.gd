extends Control
var season = 2024 + Global.season
var database : SQLite
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://cfb.db"
	database.open_db()
	label.text = str(season) + " Season"
	label2.text = "Here are your options for Week 1, Coach " + Global.name + ":"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
