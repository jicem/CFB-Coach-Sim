extends Node2D
# Variable for database
var database : SQLite
# Variable for selection box
@onready var option_button = $OptionButton
# Variable for default text
@onready var label = %Label

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add blank item to the box
	option_button.add_item("")
	# Open database from cfb.db file
	database = SQLite.new()
	database.path = "res://cfb.db"
	database.open_db()
	# Print first 49 schools
	print("Available schools:")
	var selected_array : Array = database.select_rows("teams", "tid < 50", ["school"])
	for row in selected_array:
		print("* " + row["school"])
		option_button.add_item(row["school"])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_option_button_item_selected(index):
	# Remove default text when the user makes a selection
	label.text = ""
	# If the blank option is selected, do nothing else. Otherwise, print the selected school
	if index != 0:
		var select_condition : String = "tid == " + str(index)
		var result : Array = database.select_rows("teams", select_condition, ["school"])
		for row in result:
			print("Selected school: " + row["school"])
	else: pass
