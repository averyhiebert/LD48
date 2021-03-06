extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	#dummy_data_for_testing() # TODO Remove this eventually, obviously
	var button = $CanvasLayer/CenterContainer/FrustratingTextbox/MarginContainer/VBoxContainer/ToolButton
	button.connect("pressed",self,"next_week")
	create_summary() # Note: must come after connecting button

func next_week():
	Global.week += 1
	Global.weekly_quota += 5
	get_tree().change_scene("res://Match3Game.tscn")

func dummy_data_for_testing():
	# Modify global data as though player has completed a week of match-3
	#  (Necessary for testing purposes)
	Global.last_week_picks_broken = 3
	Global.last_week_shovels_broken = 1
	Global.balance = -1000

func create_summary():
	var summary_label = $CanvasLayer/CenterContainer/FrustratingTextbox/MarginContainer/VBoxContainer/Summary
	
	var income = Global.hourly_wage * Global.hours_per_week
	var summary_text = " \n\nIncome:\n"
	#summary_text += "    Wages: $%d (%d hours @ $%d/hr )\n\n" % [income, Global.hours_per_week, Global.hourly_wage]
	summary_text += " Wages:        $ %.2f\n\n" % income
	
	summary_text += "Expenses:\n"
	summary_text += " Room & Board: $%.2f\n" % (-1* Global.ROOM_AND_BOARD)
	var interest = 0
	if Global.balance < 0:
		interest = Global.INTEREST_RATE * Global.balance
		summary_text += " Interest:     $%.2f\n" % interest
		summary_text += "   (%.2f%% of $%.2f)\n" % [Global.INTEREST_RATE*100, -1*Global.balance]
		
	summary_text += "\n"
	
	var pick_cost = -1 * Global.last_week_picks_broken * Global.PICK_PRICE
	var shovel_cost = -1 * Global.last_week_shovels_broken * Global.SHOVEL_PRICE
	summary_text += " Picks:        $%.2f\n" % pick_cost
	summary_text += "   (%d @ $%d)\n" % [Global.last_week_picks_broken,Global.PICK_PRICE]
	summary_text += " Shovels:      $%.2f\n" % shovel_cost
	summary_text += "   (%d @ $%d)\n\n" % [Global.last_week_shovels_broken,Global.SHOVEL_PRICE]
	
	var total = (income  - Global.ROOM_AND_BOARD + pick_cost + shovel_cost + interest)
	
	summary_text += "\n------------------------\n\n"
	summary_text += "Prev. Balance: $%.2f\n" % Global.balance
	summary_text += "Net Change:    $%.2f\n" % total
	
	if income < (Global.ROOM_AND_BOARD - interest):
		summary_text += "\nNote: Credit is offered\n"
		summary_text +=   "   ONLY for purchase of\n"
		summary_text +=   "   equipment from store\n"
		
		var button = $CanvasLayer/CenterContainer/FrustratingTextbox/MarginContainer/VBoxContainer/ToolButton
		button.text = "!! UNABLE TO PAY !!"
		button.disconnect("pressed",self,"next_week")
		button.connect("pressed",self,"game_over")
	else:	
		Global.balance += total
		summary_text += "New Balance:   $%.2f\n\n\n\n" % (Global.balance)
			
	summary_label.text = summary_text

func game_over():
	get_tree().change_scene("res://GameOverScreen.tscn")

