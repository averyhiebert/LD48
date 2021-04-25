extends Node2D


var gameboard
var button_grid
var tile_sprites = []
var positions = [] # Global position of each tile button

var coal = 0
var pick_damage = 0
var shovel_damage = 0
var picks_broken = 0
var shovels_broken = 0

const DAMAGE_THRESHOLD = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	button_grid = $CanvasLayer/MainInterfaceContainer/CenterContainer/VBoxContainer/PlayArea
	button_grid.connect("do_switch",self,"handle_switch")

	# Initialize the game
	gameboard = GameBoard.new()
	yield(get_tree().create_timer(0.25), "timeout") # Workaround for some sort of race condition :(
	initialize_tile_sprites()
	update_label()

func handle_switch(tile1,tile2):
	# Handle attempt by the user to switch two tiles
	if gameboard.can_do_switch(tile1,tile2):
		gameboard.do_switch(tile1,tile2)
		visually_swap_tiles(tile1,tile2)
		yield(get_tree().create_timer(0.5), "timeout")
		while gameboard.update_board():
			update_board_sprites()
			score_broken_tiles()
			yield(get_tree().create_timer(1), "timeout")
	else:
		print(gameboard.board[tile1[0]][tile1[1]], gameboard.board[tile2[0]][tile2[1]])

func update_label():
	var text = "Week %d. Progress towards weekly quota: %d/%d" % [Global.week, coal, Global.weekly_quota]
	var label = $CanvasLayer/MainInterfaceContainer/CenterContainer/VBoxContainer/TitleLabel
	label.text = text

# Scoring / debt-game related functions ========================================

func score_broken_tiles():
	var value = {
		gameboard.tiles.BIG_COAL: 2,
		gameboard.tiles.SMALL_COAL: 1,
	}
	var multiplier = [0,0,0,1,2,3,4,5,6]
	
	# Collect coal & damage:
	for deletion in gameboard.deletions:
		if deletion[0] in value:
			coal += value[deletion[0]] * multiplier[deletion[1]]
		elif deletion[0] == gameboard.tiles.PICK:
			pick_damage += multiplier[deletion[1]]
		elif deletion[0] == gameboard.tiles.SHOVEL:
			shovel_damage += multiplier[deletion[1]]
	# Break tools:
	if pick_damage > DAMAGE_THRESHOLD:
		pick_damage = 0
		picks_broken += 1
	if shovel_damage > DAMAGE_THRESHOLD:
		shovel_damage = 0
		shovels_broken += 1
	
	update_label()
	if coal >= Global.weekly_quota:
		yield(get_tree().create_timer(1), "timeout")
		end_of_week()

func end_of_week():
	Global.last_week_coal = coal
	Global.last_week_picks_broken = picks_broken
	Global.last_week_shovels_broken = shovels_broken
	get_tree().change_scene("res://EndOfWeek.tscn")

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
