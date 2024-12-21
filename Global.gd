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
var qbsneeded : int
var rbsneeded : int
var wrsneeded : int
var tesneeded : int
var olsneeded : int
var dlsneeded : int
var lbsneeded : int
var cbsneeded : int
var sneeded : int
var kneeded : int
var admood : int
var gamestarted
var seconds
var minutes
var hours
var playmins
var playhrs

# Called when the node enters the scene tree for the first time.
func _ready():
	team = 0
	coachname = ""
	face = 0
	offense = 0
	defense = 0
	season = 0
	week = 0
	admood = 3
	seconds = 0
	minutes = 0
	hours = 0
	playmins = 0
	playhrs = 0
	schedule1complete = false
	schedule2complete = false
	schedule3complete = false
	ccschedulecomplete = false
	bowlschedulecomplete = false
	semischedulecomplete = false
	finalschedulecomplete = false
	postseasonIds = []
	gamestarted = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gamestarted:
		seconds += 1
		if seconds >= 60:
			seconds = 0
			minutes += 1
			if minutes >= 60:
				minutes = 0
				hours += 1
				playmins += 1
				if hours >= 24:
					hours = 0
		if playmins >= 60:
			playmins = 0
			playhrs += 1
