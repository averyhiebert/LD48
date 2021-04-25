# Contains the main match 3 gameplay logic
# TODO: Make up my mind about naming convention "switch" vs "swap"
extends Object

class_name GameBoard

var size = 8
var board = []
var rng = RandomNumberGenerator.new()
enum tiles {PICK, BIG_COAL, SMALL_COAL, SHOVEL, NOTHING, EMPTY=-1}
var tile_textures = {
	tiles.PICK: preload("res://assets/blocks/upscaled/pickaxe_4x.png"),
	tiles.BIG_COAL: preload("res://assets/blocks/upscaled/big_coal_4x.png"),
	tiles.SMALL_COAL: preload("res://assets/blocks/upscaled/small_coal_4x.png"),
	tiles.SHOVEL: preload("res://assets/blocks/upscaled/shovel_4x.png"),
	tiles.NOTHING: preload("res://assets/blocks/upscaled/nothing_4x.png"),
	tiles.EMPTY: preload("res://assets/blocks/upscaled/outline_4x.png")
}

# Information about previous update, if it occurred
#   (Used for meta-gameplay and animation purposes)
var changed = false
var prev_run_lengths = []
var deletions = [] # Array of form [tile type, run size]
var drop_heights = [] # 2d Array telling how far each new tile fell


func _init():
	rng.randomize()
	# Initialize tiles
	for i in range(size):
		board.append([])
		for j in range(size):
			board[i].append(random_tile())
	
	reset_drop_heights(size) # Need to initialize the 2D Array
	# Update as needed to eliminate all existing matches
	while update_board(): pass
	reset_drop_heights(size) # Maybe should change this to 0, instead of size?

func reset_drop_heights(value):
	# Mainly used for initialization
	for i in range(size):
		drop_heights.append([])
		for j in range(size):
			drop_heights[i].append(value)

func random_tile():
	# Return index of a random tile
	return rng.randi_range(tiles.PICK,tiles.NOTHING)

func get_texture(row,col):   
	# Get the texture for the tile at a given location
	return tile_textures[board[row][col]]

func update_board():
	# Mutate own board state to remove runs of 3 or greater.
	# This includes recording information about what changes occurred.
	# Return true if any changes occurred, else false
	
	# Note: these two values reset regardless of whether changes occurr
	deletions = []
	prev_run_lengths = _run_lengths(board)
	
	if not _check_for_update(board):
		changed = false
		return false
	
	var run_length = _run_lengths(board)
	
	for col_i in range(size):
		var new_col = [] # i.e. what will the column look like after drop
		var col_drop_heights = []
		var curr_drop_height = 0
		
		for row_i in range(size):
			if run_length[row_i][col_i] < 3:
				# No deletion occurs, tile stays
				new_col.append(board[row_i][col_i])
			else:
				# Record deletion
				deletions.append([ board[row_i][col_i], run_length[row_i][col_i] ])
		
		# Figure out drop heights (Note reverse iteration order)
		for row_i in range(size):
			if run_length[size-row_i-1][col_i] < 3:
				col_drop_heights.append(curr_drop_height)
			else:
				curr_drop_height += 1
				
		# Account for newly added tiles:
		for i in range(size - new_col.size()):
			new_col.push_front(random_tile())
			col_drop_heights.append(curr_drop_height)
			
		# Add new column to board
		for row_i in range(size):
			board[row_i][col_i] = new_col[row_i]
			drop_heights[row_i][col_i] = col_drop_heights[size - row_i - 1]
	return true

func copy_board():
	# Return a copy of the board
	var copy = []
	for i in range(size):
		copy.append([])
		for j in range(size):
			copy[i].append(board[i][j])
	return copy

func _swapped_board(tile1,tile2):
	# Return a copy of the current board with the two values flipped.
	var new_board = copy_board()
	new_board[tile1[0]] [tile1[1]] = board[tile2[0]] [tile2[1]]
	new_board[tile2[0]] [tile2[1]] = board[tile1[0]] [tile1[1]]
	return new_board
	
func set_board(new_board):
	for i in range(size):
		for j in range(size):
			board[i][j] = new_board[i][j]

func do_switch(tile1,tile2):
	# Switch two values, but do not update the board yet
	var swapped = _swapped_board(tile1,tile2)
	set_board(swapped)

func can_do_switch(tile1,tile2):
	# Return true if the two tiles can be switched (i.e. it would lead
	#  to an update), or false otherwise
	var swapped = _swapped_board(tile1,tile2)
	return _check_for_update(swapped)

func _check_for_update(new_board):
	# Return true if an update must be performed on new_board,
	#  or false otherwise
	var run_length = _run_lengths(new_board)
	
	var max_run = 0
	for i in range(size):
		max_run = max(max_run,run_length[i].max())
	
	return max_run >= 3
	

func _run_lengths(new_board):
	# Return grid of values corresponding to maximum run length that each
	#  tile is involved in, as well as the max over the entire board.
	#  (i.e. 3 or greater should be removed, and if max is 2 or 1 then no
	#    change should take place)
	#  (NO SIDE EFFECTS)
	var run_lengths = []
	
	# Check rows:
	for i in range(size):
		run_lengths.append(_row_run_lengths(new_board[i]))
		
	# Check columns:
	for i in range(size):
		var col = []
		for j in range(size):
			col.append(new_board[j][i])
		var col_runlengths = _row_run_lengths(col)
		for j in range(size):
			run_lengths[j][i] = max(run_lengths[j][i],col_runlengths[j])
	
	return run_lengths

func _row_run_lengths(row):
	# Given an array of tiles, return an array of values representing
	#  the run length of each run.  It's technically O(n^2), but since
	#  n = 8 = constant for the purposes of this game, it'll be fine.
	var run_lengths = []
	
	var prev_symbol = tiles.EMPTY
	var count = 0
	for i in range(row.size()):
		run_lengths.push_back(1)
		if row[i] == prev_symbol:
			count += 1
			for j in range(count):
				run_lengths[i - j] = count
		else:
			count = 1
			prev_symbol = row[i]
	return run_lengths




