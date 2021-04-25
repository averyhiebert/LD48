extends GridContainer

export (PackedScene) var BlockButton

signal do_switch(tile1,tile2)

var buttons = []
var selection = null # Currently selected tile

# Called when the node enters the scene tree for the first time.
func _ready():
	# Instantiate 8x8 grid of child buttons
	for i in range(8):
		buttons.push_back([])
		for j in range(8):
			var button = BlockButton.instance()
			button.connect('pressed',self,'button_pressed',[i,j,button])
			button.set_normal_texture(preload("res://assets/blocks/upscaled/outline_4x.png"))
			button.modulate = Color(0,0,0,0) # i.e. make button invisible
			buttons[i].push_back(button)
			add_child(button) # Actually add the button to scene


func button_pressed(row,col,button):
	if not selection:
		selection = [row,col]
	elif selection[0] == row and selection[1] == col:
		selection = null
	else:
		# Emit "swap" signal for main game
		emit_signal("do_switch",selection,[row,col])
		selection = null

func draw_board(gameboard):
	# Given a gameboard, set button icons to match tiles in selected board.
	# This is probably temporary (since in the end there will tile be sprites 
	#    separate from the buttons themselves, which will be invisible)
	for i in range(gameboard.size):
		for j in range(gameboard.size):
			buttons[i][j].set_normal_texture(gameboard.get_texture(i,j))

func button_positions():
	# Return array of positions of all buttons (workaround for positioning that
	#   isn't making sense to me)
	var positions = []
	for i in range(buttons.size()):
		positions.append([])
		for j in range(buttons[i].size()):
			positions[i].append(buttons[i][j].rect_global_position)
	return positions
