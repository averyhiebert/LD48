extends Node

var weekly_quota = 100 # How much coal is needed to trigger end-of-week scene
var week = 1

var hours_per_week = 60
var hourly_wage = 5

const PICK_PRICE = 34
const SHOVEL_PRICE = 34
const ROOM_AND_BOARD = 200
const INTEREST_RATE = 0.15

var balance = 0

var last_week_coal = 0
var last_week_picks_broken = 0
var last_week_shovels_broken = 0
