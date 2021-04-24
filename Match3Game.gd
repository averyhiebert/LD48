extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var gameboard
var button_grid
var tile_sprites = []
var positions = [] # Global position of each tile button

# Called when the node enters the scene tree for the first time.
func _ready():
	button_grid = $CanvasLayer/MainInterfaceContainer/CenterContainer/VBoxContainer/PlayArea
	button_grid.connect("do_switch",self,"do_switch")

	# Initialize the game
	gameboard = GameBoard.new()
	#button_grid.draw_board(gameboard) # TODO Replace w/ separate sprites
	yield(get_tree().create_timer(0.25), "timeout") # Workaround for some sort of race condition :(
	initialize_tile_sprites()

func do_switch(tile1,tile2):
	# Handle attempt by the user to switch two tiles
	gameboard.do_switch(tile1,tile2)
	#button_grid.draw_board(gameboard)
	update_board_sprites()

func create_tile_sprite(i,j):
	# Return a sprite appropriately initialized for the given tile
	var sprite = Sprite.new()
	sprite.texture = gameboard.get_texture(i,j)
	sprite.position = positions[i][j] + Vector2(sprite.texture.get_width()/2,sprite.texture.get_height()/2)
	return sprite

func initialize_tile_sprites():
	positions = button_grid.button_positions()
	
	for i in range(gameboard.size):
		tile_sprites.append([])
		for j in range(gameboard.size):
			var sprite = create_tile_sprite(i,j)
			tile_sprites[i].append(sprite) # TODO Move to better location
			
			
			# Add track to animation
			#  TODO separate function somehow
			var drop_height = 8 # todo update this
			var gap_size = positions[1][0].y - positions[0][0].y
			var offset = drop_height * gap_size
			var start_pos = sprite.position - Vector2(0,offset)
			var end_pos = sprite.position
			
			sprite.position = start_pos
			add_child(sprite) # TODO Move to better location
			
			var tween = Tween.new()
			tween.playback_process_mode = tween.TWEEN_PROCESS_IDLE
			add_child(tween)
			tween.interpolate_property(sprite, "position",
					start_pos, end_pos, 0.8,
					Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			tween.start()

func kill_tile(old_sprite):
	#  Animate out tile using tween, then delete it.
	# TODO: Make it so we can use a single tween for each board update
	var tween = Tween.new()
	tween.playback_process_mode = tween.TWEEN_PROCESS_IDLE
	add_child(tween)
	tween.interpolate_property(old_sprite,"modulate",
		Color(1,1,1,1),Color(1,1,1,0),1,
		Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.interpolate_property(old_sprite,"position",
		old_sprite.position,old_sprite.position + Vector2(10,100),1,
		Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.connect("tween_all_completed",self,"remove_child",[old_sprite])
	tween.start()

func update_board_sprites():
	# For now, just update sprites to match the new board
	positions = button_grid.button_positions()
	for i in range(gameboard.size):
		for j in range(gameboard.size):
			var old_sprite = tile_sprites[i][j]
			remove_child(old_sprite)  #kill_tile(old_sprite)
			
			var new_sprite = create_tile_sprite(i,j)
			tile_sprites[i][j] = new_sprite
			add_child(new_sprite)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
