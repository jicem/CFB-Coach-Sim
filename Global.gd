extends Node
var team : int
var coachname : String
var face : int
var offense : int
var defense : int
var season : int
var week : int
var state : int
var schedule1complete : bool
var schedule2complete : bool
var schedule3complete : bool
var ccschedulecomplete : bool
var bowlschedulecomplete : bool
var semischedulecomplete : bool
var finalschedulecomplete : bool
var postseasonIds : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	team = 0
	coachname = ""
	face = 0
	offense = 0
	defense = 0
	season = 0
	week = 0
	schedule1complete = false
	schedule2complete = false
	schedule3complete = false
	ccschedulecomplete = false
	bowlschedulecomplete = false
	semischedulecomplete = false
	finalschedulecomplete = false
	postseasonIds = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
