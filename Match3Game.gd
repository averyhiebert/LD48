extends Node2D


var gameboard
var button_grid
var tile_sprites = []
var positions = [] # Global position of each tile button

# Called when the node enters the scene tree for the first time.
func _ready():
	button_grid = $CanvasLayer/MainInterfaceContainer/CenterContainer/VBoxContainer/PlayArea
	button_grid.connect("do_switch",self,"handle_switch")

	# Initialize the game
	gameboard = GameBoard.new()
	yield(get_tree().create_timer(0.25), "timeout") # Workaround for some sort of race condition :(
	initialize_tile_sprites()

func handle_switch(tile1,tile2):
	# Handle attempt by the user to switch two tiles
	if gameboard.can_do_switch(tile1,tile2):
		gameboard.do_switch(tile1,tile2)
		visually_swap_tiles(tile1,tile2)
		yield(get_tree().create_timer(0.5), "timeout")
		while gameboard.update_board():
			update_board_sprites()
			yield(get_tree().create_timer(1), "timeout")
	else:
		print(gameboard.board[tile1[0]][tile1[1]], gameboard.board[tile2[0]][tile2[1]])




# Individual animation functions ===============================================

func tiles_to_distance(n):
	# Convert a number of tiles to a distance in pixels
	var gap_size = positions[1][0].y - positions[0][0].y
	return n * gap_size

func visually_swap_tiles(tile1,tile2):
	var sprite1 = tile_sprites[tile1[0]][tile1[1]]
	var sprite2 = tile_sprites[tile2[0]][tile2[1]]
	var tween = Tween.new()
	tween.playback_process_mode = tween.TWEEN_PROCESS_IDLE
	add_child(tween)
	tween.interpolate_property(sprite1, "position",
			sprite1.position, sprite2.position, 0.5,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.interpolate_property(sprite2, "position",
			sprite2.position, sprite1.position, 0.5,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	
	
func drop_tile(sprite,drop_size):
	# Tween a tile down from its original height to its final position
	var tween = Tween.new()
	tween.playback_process_mode = tween.TWEEN_PROCESS_IDLE
	add_child(tween)
	tween.interpolate_property(sprite, "position",
			sprite.position, sprite.position + Vector2(0,tiles_to_distance(drop_size)), 1,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()

func kill_tile(old_sprite):
	#  Animate out tile using tween, then delete it.
	# TODO: Make it so we can use a single tween for each board update
	var tween = Tween.new()
	tween.playback_process_mode = tween.TWEEN_PROCESS_IDLE
	add_child(tween)
	tween.interpolate_property(old_sprite,"modulate",
		Color(1,1,1,1),Color(1,1,1,0),0.2,
		Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.connect("tween_all_completed",self,"remove_child",[old_sprite])
	tween.start()

# Initialize and update the board ==============================================

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
			
			# Do the drop tweening
			var drop_height = 8 # todo update this
			var start_pos = sprite.position - Vector2(0,tiles_to_distance(drop_height))
			
			sprite.position = start_pos
			add_child(sprite) # TODO Move to better location
			drop_tile(sprite,8)

func update_board_sprites():
	# For now, just update sprites to match the new board
	positions = button_grid.button_positions()
	for i in range(gameboard.size):
		for j in range(gameboard.size):
			#if gameboard.drop_heights[i][j] == 0:
			#	# Sprite does not animate, just appears
			#	tile_sprites[i][j].set_texture(gameboard.get_texture(i,j))
			#	continue
				
			var old_sprite = tile_sprites[i][j]
			if gameboard.prev_run_lengths[i][j] > 3:
				# Tile should be destroyed
				kill_tile(old_sprite)
			else:
				remove_child(old_sprite)
			
			var new_sprite = create_tile_sprite(i,j)
			tile_sprites[i][j] = new_sprite
			add_child(new_sprite)
			
			if gameboard.drop_heights[i][j] > 0:
				# Do the drop tweening
				var start_pos = new_sprite.position - Vector2(0,tiles_to_distance(gameboard.drop_heights[i][j]))
				new_sprite.position = start_pos
				add_child(new_sprite) # TODO Move to better location
				drop_tile(new_sprite,gameboard.drop_heights[i][j])
