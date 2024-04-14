extends Control
var wins : int
var expectedWins : int
var database : SQLite
var team = Global.team
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
	database.path = "res://cfb.db"
	database.open_db()
	# Compare wins to expected wins
	var array : Array = database.select_rows("teams1", "tid == " + str(team), ["*"])
	for row in array:
		wins = row["wins"]
		expectedWins = row["prestige"] / 10
		print(expectedWins)
	# Options for the second paragraph
	if wins == expectedWins:
		label3.text = "Doing OK doesn't bring in the applicants and the donations. Mediocrity can be worse than losing. I hope you have some plan to get us to the next level."
	elif wins == expectedWins - 1:
		label3.text = "What are you doing? If you keep missing expectations, I'll actually have to do stuff, and I hate doing stuff! Turn it around, now."
	elif wins <= expectedWins - 2:
		label3.text = "I need some wins. Our fans hate losers. Our boosters hate losers. What's your strategy? Keep on losing until I fire you? You're making good progress, then."
	elif wins == expectedWins + 1:
		label3.text = "I'm pleased with our regular season performance. Now to make some calls. Hopefully we can get some better teams in this conference. Anyone could beat these scrubs."
	elif wins >= expectedWins + 2:
		label3.text = "I like the roster you've put together. We'll be at the top of our conference for a long time."
	# Options for the third parageaph
	if wins == expectedWins:
		label4.text = "You bore me. Everything about you, it's just boring. Come talk to me when you've got that stadium paid for and won me a championship."
	elif wins == expectedWins - 1:
		label4.text = "Bye."
	elif wins <= expectedWins - 2:
		label4.text = "I'm watching you. Seriously, one of your assistant coaches is a spy. Don't fuck up."
	elif wins == expectedWins + 1:
		label4.text = "Overall, I'm happy with the progress you've made,"
	elif wins >= expectedWins + 2:
		label4.text = "Good work. Let's keep it going. Championships don't win themselves."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	get_tree().change_scene_to_file("res://playerlist.tscn")

func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://schoolselection.tscn")
