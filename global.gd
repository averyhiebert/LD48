extends Node

var weekly_quota = 100 # How much coal is needed to trigger end-of-week scene
var week = 1

var hours_per_week = 60
var hourly_wage = 5

const PICK_PRICE = 40
#const SHOVEL_PRICE = 40
const SHOVEL_PRICE = 40
const ROOM_AND_BOARD = 200
const INTEREST_RATE = 0.15

var balance = 0

var last_week_coal = 0
var last_week_picks_broken = 0
var last_week_shovels_broken = 0

func reset():
	# I know this is terrible from a DRY perspective,
	#   but I'm running out of time (Sorry)
	weekly_quota = 100 # How much coal is needed to trigger end-of-week scene
	week = 1
	hours_per_week = 60
	hourly_wage = 5
	balance = 0
	last_week_coal = 0
	last_week_picks_broken = 0
	last_week_shovels_broken = 0
	
