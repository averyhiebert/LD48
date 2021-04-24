extends GridContainer

export (PackedScene) var BlockButton

signal do_switch(tile1,tile2)

var buttons = []
var textures = {}

var selection = null # Currently selected tile

# Called when the node enters the scene tree for the first time.
func _ready():
	# Instantiate 8x8 grid of child buttons
	for i in range(8):
		buttons.push_back([])
		for j in range(8):
			var button = BlockButton.instance()
			button.connect('pressed',self,'button_pressed',[i,j,button])
			buttons[i].push_back(button)
			add_child(button) # Actually add the button to scene


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func button_pressed(row,col,button):
	# Note for future: button.rect_global_position gives global position of button
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
