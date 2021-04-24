extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var gameboard
var playarea

# Called when the node enters the scene tree for the first time.
func _ready():
	playarea = $MainInterfaceContainer/PlayArea
	
	# Begin the game logic
	print("DEBUG: Instantiating match 3 game")
	gameboard = GameBoard.new()
	
	# Update playarea buttons to match game board
	playarea.draw_board(gameboard)
	playarea.connect("do_switch",self,"do_switch")

func do_switch(tile1,tile2):
	gameboard.do_switch(tile1,tile2)
	playarea.draw_board(gameboard)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
