extends Control
var wins : int
var prestige : int
var expectedWins : int
var database : SQLite
var team = Global.team
@onready var button = $Button
@onready var button2 = $Button2
@onready var label2 = %Label2
@onready var label3 = %Label3
@onready var label4 = %Label4

# Called when the node enters the scene tree for the first time.
func _ready():
	var activities = [
		"bringing out all the stops for football recruits, you know, booze, drugs, the usual.",
		"planning my daughter's million dollar wedding with AD funds.",
		"finding more of those professors who know how to give the right grades for our athletes.",
		"covering up that..., well let's just say this conversation never took place.",
		"going to conferences in Tahiti.",
		"getting the city's biggest mob bosses to help fund our NIL collective.",
		"buying cars and jewellery for middle school football prospects so they'll come here when they graduate."
	]
	var random = randi() % 7
	# Select a random activity and display it
	var activity = activities[random]
	label2.text += activity
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	# Compare wins to expected wins
	var array : Array = database.select_rows("teams1", "tid == " + str(team), ["*"])
	for row in array:
		wins = row["wins"]
		prestige = row["prestige"]
		expectedWins = row["prestige"] / 10 + 2
		if wins == expectedWins - 1:
			Global.admood -= 1
			if prestige - 5 > 0:
				var data = {
					"prestige" : prestige - 5
				}
				database.update_rows("teams1", "tid == " + str(team), data)
			else:
				var data = {
					"prestige" : 0
				}
				database.update_rows("teams1", "tid == " + str(team), data)
		elif wins <= expectedWins - 2:
			Global.admood -= 1
			if prestige - 10 > 0:
				var data = {
					"prestige" : prestige - 10
				}
				database.update_rows("teams1", "tid == " + str(team), data)
			else:
				var data = {
					"prestige" : 0
				}
				database.update_rows("teams1", "tid == " + str(team), data)
		elif wins == expectedWins + 1:
			Global.admood += 1
			if prestige + 5 > 100:
				var data = {
					"prestige" : 100
				}
				database.update_rows("teams1", "tid == " + str(team), data)
			else:
				var data = {
					"prestige" : prestige + 5
				}
				database.update_rows("teams1", "tid == " + str(team), data)
		elif wins >= expectedWins + 2:
			Global.admood += 1
			if prestige + 10 > 100:
				var data = {
					"prestige" : 100
				}
				database.update_rows("teams1", "tid == " + str(team), data)
			else:
				var data = {
					"prestige" : prestige + 10
				}
				database.update_rows("teams1", "tid == " + str(team), data)
		
	# Options for the second paragraph
	if wins > 13:
		label3.text = "Anyway, I'm loving the roster we have. We'll be at the top of our conference for a long time."
	elif wins > 10:
		label3.text = "I'm pleased with our regular season performance. Now to make some calls. Hopefully we can get some better teams in this conference. Anyone could beat these scrubs."
	elif wins > 7:
		label3.text = "Don't think you can coast on your past success for too long. Work harder so I can continue not working at all."
	elif wins > 4:
		label3.text = "Doing OK doesn't bring in the applicants and the donations. Mediocrity can be worse than losing. I hope you have some plan to get us to the next level."
	elif wins > 1:
		label3.text = "I need some wins. Our fans hate losers. Our boosters hate losers. What's your strategy? Keep on losing until I fire you? You're making good progress, then."
	else:
		label3.text = "What the hell did you do to our program?!"
	# Options for the third parageaph
	if Global.admood < 1:
		label4.text = "You've been an all-around disappointment. You're fired."
	elif wins == expectedWins or wins == expectedWins - 1:
		label4.text = "You bore me. Everything about you, it's just boring. Come talk to me when you've got that stadium paid for and won me a championship."
	elif wins == expectedWins - 2 or wins == expectedWins - 3:
		label4.text = "Bye."
	elif wins < expectedWins - 3:
		label4.text = "I'm watching you. Seriously, one of your assistant coaches is a spy. Don't fuck up."
	elif wins == expectedWins + 1 or wins == expectedWins + 2:
		label4.text = "Overall, I'm happy with the progress you've made."
	elif wins > expectedWins + 2:
		label4.text = "Good work. Let's keep it going. Championships don't win themselves."
	if Global.admood < 1:
		button.hide()
	else: button2.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	Global.schedule1complete = false
	Global.schedule2complete = false
	Global.schedule3complete = false
	Global.ccschedulecomplete = false
	Global.bowlschedulecomplete = false
	Global.semischedulecomplete = false
	Global.finalschedulecomplete = false
	Global.postseasonIds = []
	get_tree().change_scene_to_file("res://season/departures.tscn")


func _on_button_2_pressed():
	Global.team = 0
	Global.coachname = ""
	Global.face = 0
	Global.offense = 0
	Global.defense = 0
	Global.season = 0
	Global.admood = 3
	Global.schedule1complete = false
	Global.schedule2complete = false
	Global.schedule3complete = false
	Global.ccschedulecomplete = false
	Global.bowlschedulecomplete = false
	Global.semischedulecomplete = false
	Global.finalschedulecomplete = false
	Global.postseasonIds = []
	get_tree().change_scene_to_file("res://schoolselection.tscn")
