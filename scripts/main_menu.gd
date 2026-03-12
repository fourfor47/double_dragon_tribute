extends Control

func _ready():
	SoundManager.play_music("menu")  # TODO

func _on_start_pressed():
	# 直接加载第一关
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_controls_pressed():
	$ControlsPanel.visible = true

func _on_close_controls():
	$ControlsPanel.visible = false

func _on_quit_pressed():
	get_tree().quit()
