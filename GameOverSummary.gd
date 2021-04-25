extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	text = """After %d weeks you were unable to
	meet your financial obligations,
	and ended up in debtors' prison.
	
	""" % Global.week

