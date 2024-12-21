extends Control
var season = 2024 + Global.season
var database : SQLite
var treerow : TreeItem
@onready var tree = $Tree
@onready var button = $Button
@onready var label = %Label
@onready var label2 = %Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	button.hide()
	# Display the current season at the top of the screen and display next week's number in the button
	label.text = str(season) + " Season"
	# Add column names for tree
	tree.set_column_title(0, "Ranking")
	tree.set_column_title(1, "School Name")
	tree.set_column_title(2, "Wins")
	tree.set_column_title(3, "Losses")
	# The root node is hidden in the tree
	treerow = tree.create_item()
	treerow.set_text(0, "Hidden")
	treerow.set_text(1, "Hidden")
	treerow.set_text(2, "Hidden")
	treerow.set_text(3, "Hidden")
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://data/cfb.db"
	database.open_db()
	# Query to retrieve the top 40 teams by wins
	var query = "SELECT * FROM teams1 WHERE ranking > 0 ORDER BY ranking ASC LIMIT 40"
	database.query(query)
	for i in database.query_result:
		# Create variable for tree row
		treerow = tree.create_item()
		# Print data to console
		print(i["ranking"])
		print(i["school"])
		# Add data to tree
		var textRank = str(i["ranking"])
		var textWins = str(i["wins"])
		var textLosses = str(i["losses"])
		treerow.set_text(0, textRank)
		treerow.set_text(1, i["school"])
		treerow.set_text(2, textWins)
		treerow.set_text(3, textLosses)
		
		# If it's the regular season, you'll always show the practice button
		if(Global.week < 13):
			button.show()
		else:
			# Only show the practice button if the player's team is active this week
			if Global.postseasonIds.has(Global.team):
				button.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_pressed():
	get_tree().change_scene_to_file("res://season/practice.tscn")

func _on_button_2_pressed():
	if(Global.week == 13):
		get_tree().change_scene_to_file("res://season/ccsimulation.tscn")
	elif(Global.week == 14):
		get_tree().change_scene_to_file("res://season/bowlsimulation.tscn")
	else:
		get_tree().change_scene_to_file("res://season/simulation.tscn")


func _on_coach_button_pressed():
	get_tree().change_scene_to_file("res://coachoffice.tscn")


func _on_history_button_pressed():
	get_tree().change_scene_to_file("res://history.tscn")


func _on_achievement_button_pressed():
	get_tree().change_scene_to_file("res://achievements.tscn")
