extends Control
var database : SQLite
@onready var timer = $Timer
@onready var label = %Label
@onready var label2 = %Label2
@onready var label3 = %Label3
@onready var label4 = %Label4
@onready var label5 = %Label5
@onready var label6 = %Label6
@onready var label7 = %Label7
@onready var label8 = %Label8
@onready var label9 = %Label9
@onready var label10 = %Label10
@onready var label11 = %Label11

# Called when the node enters the scene tree for the first time.
func _ready():
	label2.text += str(Global.qbsneeded)
	label3.text += str(Global.rbsneeded)
	label4.text += str(Global.wrsneeded)
	label5.text += str(Global.tesneeded)
	label6.text += str(Global.olsneeded)
	label7.text += str(Global.dlsneeded)
	label8.text += str(Global.lbsneeded)
	label9.text += str(Global.cbsneeded)
	label10.text += str(Global.sneeded)
	label11.text += str(Global.kneeded)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_qb_button_pressed():
	if(Global.qbsneeded > 0):
		get_tree().change_scene_to_file("res://recruiting/qbrecruits.tscn")
	else: pass


func _on_rb_button_pressed():
	if(Global.rbsneeded > 0):
		get_tree().change_scene_to_file("res://recruiting/rbrecruits.tscn")
	else: pass


func _on_wr_button_pressed():
	if(Global.wrsneeded > 0):
		get_tree().change_scene_to_file("res://recruiting/wrrecruits.tscn")
	else: pass


func _on_te_button_pressed():
	if(Global.tesneeded > 0):
		get_tree().change_scene_to_file("res://recruiting/terecruits.tscn")
	else: pass

func _on_ol_button_pressed():
	if(Global.olsneeded > 0):
		get_tree().change_scene_to_file("res://recruiting/olrecruits.tscn")
	else: pass

func _on_dl_button_pressed():
	if(Global.dlsneeded > 0):
		get_tree().change_scene_to_file("res://recruiting/dlrecruits.tscn")
	else: pass

func _on_lb_button_pressed():
	if(Global.lbsneeded > 0):
		get_tree().change_scene_to_file("res://recruiting/lbrecruits.tscn")
	else: pass

func _on_cb_button_pressed():
	if(Global.cbsneeded > 0):
		get_tree().change_scene_to_file("res://recruiting/cbrecruits.tscn")
	else: pass

func _on_s_button_pressed():
	if(Global.sneeded > 0):
		get_tree().change_scene_to_file("res://recruiting/srecruits.tscn")
	else: pass

func _on_k_button_pressed():
	if(Global.kneeded > 0):
		get_tree().change_scene_to_file("res://recruiting/krecruits.tscn")
	else: pass

func _on_button_pressed():
	label.text = "Adding recruits to teams..."
	timer.start()
	
func _on_timer_timeout():
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	for i in range(8):
		# Add players to each team with less than 22 roster spots
		var array : Array = database.select_rows("teams1", "prestige > 80", ["*"])
		for row in array:
			var current_tid = row["tid"]
			if current_tid == Global.team: continue
			var player_count_query = "SELECT COUNT(*) as count FROM players1 WHERE tid = %d" % current_tid
			database.query(player_count_query)
			for r in database.query_result:
				if r["count"] < 22:
					var player_sort_query = "SELECT * FROM recruits ORDER BY rating DESC"
					database.query(player_sort_query)
					var p = database.query_result
					var data = {
						"firstname" : p[0]["firstname"],
						"lastname" : p[0]["lastname"],
						"tid" : row["tid"],
						"birthyear" : p[0]["birthyear"],
						"position" : p[0]["position"],
						"jersey" : p[0]["jersey"],
						"state" : p[0]["state"],
						"rating" : p[0]["rating"]
					}
					database.insert_row("players1", data)
					print(row["school"], " has ", r["count"], " players.")
					var delete_query = "DELETE FROM recruits WHERE pid = %d" % p[0]["pid"]
					database.query(delete_query)
	for i in range(7):
		# Add players to each team with less than 22 roster spots
		var array : Array = database.select_rows("teams1", "prestige <= 80", ["*"])
		for row in array:
			var current_tid = row["tid"]
			if current_tid == Global.team: continue
			var player_count_query = "SELECT COUNT(*) as count FROM players1 WHERE tid = %d" % current_tid
			database.query(player_count_query)
			for r in database.query_result:
				if r["count"] < 22:
					var player_sort_query = "SELECT * FROM recruits"
					database.query(player_sort_query)
					var p = database.query_result
					if p.size() > 0:
						var selected_recruit = p[0]
						var data = {
							"firstname" : selected_recruit["firstname"],
							"lastname" : selected_recruit["lastname"],
							"tid" : row["tid"],
							"birthyear" : selected_recruit["birthyear"],
							"position" : selected_recruit["position"],
							"jersey" : selected_recruit["jersey"],
							"state" : selected_recruit["state"],
							"rating" : selected_recruit["rating"]
						}
						database.insert_row("players1", data)
						var delete_query = "DELETE FROM recruits WHERE pid = %d" % selected_recruit["pid"]
						database.query(delete_query)
	get_tree().change_scene_to_file("res://recruiting/transfers.tscn")
