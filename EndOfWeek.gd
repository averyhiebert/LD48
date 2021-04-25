extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#dummy_data_for_testing() # TODO Remove this eventually, obviously
	create_summary()
	
	var button = $CanvasLayer/CenterContainer/FrustratingTextbox/MarginContainer/VBoxContainer/ToolButton
	button.connect("pressed",self,"next_week")

func next_week():
	Global.week += 1
	Global.weekly_quota += 5
	get_tree().change_scene("res://Match3Game.tscn")

func dummy_data_for_testing():
	# Modify global data as though player has completed a week of match-3
	#  (Necessary for testing purposes)
	Global.last_week_picks_broken = 3
	Global.last_week_shovels_broken = 1
	Global.balance = -99

func create_summary():
	var summary_label = $CanvasLayer/CenterContainer/FrustratingTextbox/MarginContainer/VBoxContainer/Summary
	
	var income = Global.hourly_wage * Global.hours_per_week
	var summary_text = " \n\n\nIncome:\n"
	summary_text += "    Wages: $%d (%d hours @ $%d/hr )\n\n" % [income, Global.hours_per_week, Global.hourly_wage]
	
	summary_text += "Expenses:\n"
	summary_text += "    Room & Board: $%d\n" % (-1* Global.ROOM_AND_BOARD)
	
	var pick_cost = -1 * Global.last_week_picks_broken * Global.PICK_PRICE
	var shovel_cost = -1 * Global.last_week_shovels_broken * Global.SHOVEL_PRICE
	summary_text += "    Picks:    $%d (%d @ $%d)\n" % [pick_cost,Global.last_week_picks_broken,Global.PICK_PRICE]
	summary_text += "    Shovels: $%d (%d @ $%d)\n\n" % [shovel_cost,Global.last_week_shovels_broken,Global.SHOVEL_PRICE]
	
	var interest = 0
	if Global.balance < 0:
		interest = Global.INTEREST_RATE * Global.balance
		summary_text += "    Interest: $%.2f (%.2f%% on $%.2f)\n" % [interest, Global.INTEREST_RATE*100, -1*Global.balance]
	
	var total = (income  - Global.ROOM_AND_BOARD + pick_cost + shovel_cost + interest)
	
	summary_text += "\n---------------------------\n"
	summary_text += "\nNet Change in Balance: $%.2f\n" % total
	
	Global.balance += total
	summary_text += "New Balance: $%.2f\n\n\n\n" % (Global.balance)
	
	summary_label.text = summary_text
