extends Control
var database : SQLite
var team = Global.team
@onready var ocoord = %OCoord
@onready var oscheme = %OCoordScheme
@onready var dcoord = %DCoord
@onready var dscheme = %DCoordScheme

# Called when the node enters the scene tree for the first time.
func _ready():
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	# Select offensive coordinator from table
	var oc_query = "SELECT ocid FROM teams1 WHERE tid = %d" % team
	database.query(oc_query)
	for i in database.query_result:
		var scheme
		if i["ocid"] == 0: ocoord.text += "None"
		else:
			var ocid = i["ocid"]
			var new_query = "SELECT * FROM offcoordinators WHERE ocid = %d" % ocid
			database.query(new_query)
			for j in database.query_result:
				ocoord.text += j["firstname"]
				ocoord.text += " "
				ocoord.text += j["lastname"]
				# Convert scheme number to text
				if j["scheme"] == 0:
					scheme = "Balanced"
				elif j["scheme"] == 1:
					scheme = "Pass First"
				else:
					scheme = "Run First"
				oscheme.text += scheme
	# Select defensive coordinator from table
	var dc_query = "SELECT dcid FROM teams1 WHERE tid = %d" % team
	database.query(dc_query)
	for i in database.query_result:
		var scheme
		if i["dcid"] == 0: dcoord.text += "None"
		else:
			var dcid = i["dcid"]
			var new_query = "SELECT * FROM defcoordinators WHERE dcid = %d" % dcid
			database.query(new_query)
			for j in database.query_result:
				dcoord.text += j["firstname"]
				dcoord.text += " "
				dcoord.text += j["lastname"]
				# Convert scheme number to text
				if j["scheme"] == 0:
					scheme = "Balanced"
				elif j["scheme"] == 1:
					scheme = "Pass First"
				else:
					scheme = "Run First"
				dscheme.text += scheme

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	get_tree().change_scene_to_file("res://save.tscn")

func _on_button_2_pressed():
	var array : Array = database.select_rows("teams1", "tid == " + str(team), ["*"])
	for r in array:
		var ocid = r["ocid"]
		var budget = r["budget"]
		var array1 : Array = database.select_rows("offcoordinators", "ocid == " + str(ocid), ["*"])
		for s in array1:
			budget += s["salary"]
			database.update_rows("teams1", "tid == " + str(team), {"budget": budget})
		database.update_rows("teams1", "tid == " + str(team), {"ocid": 0})
	get_tree().change_scene_to_file("res://recruiting/hireoc.tscn")


func _on_button_3_pressed():
	var array : Array = database.select_rows("teams1", "tid == " + str(team), ["*"])
	for r in array:
		var dcid = r["dcid"]
		var budget = r["budget"]
		var array1 : Array = database.select_rows("defcoordinators", "dcid == " + str(dcid), ["*"])
		for s in array1:
			budget += s["salary"]
			database.update_rows("teams1", "tid == " + str(team), {"budget": budget})
		database.update_rows("teams1", "tid == " + str(team), {"dcid": 0})
	get_tree().change_scene_to_file("res://recruiting/hiredc.tscn")
