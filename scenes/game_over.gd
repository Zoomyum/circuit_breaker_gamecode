extends Control

# res://scripts/GameOver.gd

@onready var explode_label  : Label  = $ExplodeLabel
@onready var time_label     : Label  = $TimeLabel
@onready var restart_button : Button = $RestartButton
@onready var quit_button : Button = $BackButton
@onready var click_player : AudioStreamPlayer = $ClickPlayer

func _ready() -> void:
	explode_label.text = get_meta("exploded_node") + " EXPLODED"
	time_label.text    = "TIME SURVIVED    " + get_meta("time_text")
	restart_button.pressed.connect(_on_restart)
	quit_button.pressed.connect(on_quit)


func _on_restart() -> void:
	click_player.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/GameScreen.tscn")
func on_quit() -> void:
	click_player.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
