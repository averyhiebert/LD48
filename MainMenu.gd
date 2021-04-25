extends Node2D

func _ready():
	Global.reset()

func _on_StartButton_pressed():
	get_tree().change_scene("res://Match3Game.tscn")


func _on_InstructionsButton_pressed():
	get_tree().change_scene("res://InstructionsScreen.tscn")
