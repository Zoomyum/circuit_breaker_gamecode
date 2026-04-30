extends Node

var player : AudioStreamPlayer

func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.stream = load("res://assets/audio/music.wav")
	player.autoplay = true
	add_child(player)
	player.play()
