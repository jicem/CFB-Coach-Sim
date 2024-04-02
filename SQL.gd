extends Control
@onready var playername = $Label/Name
@onready var score = $Label2/Score

var database : SQLite
# Called when the node enters the scene tree for the first time.
func _ready():
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_create_table_button_down():
	var table = {
		"id" : {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		"name" : {"data_type":"text"},
		"score" : {"data_type":"int"}
	}
	database.create_table("players", table)


func _on_insert_data_button_down():
	var data = {
		"Name" : playername.text,
		"Score" : int(score.text)
	}
	database.insert_row("players", data)

func _on_select_data_button_down():
	print(database.select_rows("players", "score > 10", ['*']))


func _on_update_data_button_down():
	database.update_rows("players", "name = '" + playername.text + "'", {"score": int(score.text)})


func _on_delete_data_button_down():
	database.delete_rows("players", "name = '" + playername.text + "'")

func _on_custom_select_button_down():
	database.query("SELECT * FROM players WHERE score > 10")
	for i in database.query_result: print(i)
