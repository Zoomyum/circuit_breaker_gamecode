extends Control

@onready var back_button : Button = $BackButton
@onready var click_player : AudioStreamPlayer = $ClickPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_button.pressed.connect(_on_back)
	back_button.pressed.connect(_on_click_sound)

func _on_back() -> void:
	click_player.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
	
func _on_click_sound() -> void:
	if click_player and click_player.is_inside_tree():
		click_player.play()
