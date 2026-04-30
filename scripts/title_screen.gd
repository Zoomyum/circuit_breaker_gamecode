extends Control

# Attach to: res://scenes/TitleScreen.tscn root node
# Script lives at: res://scripts/TitleScreen.gd
#
# Scene tree you need to build manually in Godot:
#
# Control  (root, Full Rect anchors)
#   ColorRect    — name it "BG"
#   Label        — name it "TitleLabel"
#   Label        — name it "WarnLabel"
#   Button       — name it "StartButton"
#   Button       — name it "QuitButton"

@onready var warn_label   : Label  = $WarnLabel
@onready var start_button : Button = $StartButton
@onready var quit_button  : Button = $QuitButton
@onready var how_button  : Button = $HowButton
@onready var click_player : AudioStreamPlayer = $ClickPlayer

var _flicker_time : float = 0.0
var _next_flick   : float = 0.15


func _ready() -> void:
	# ── TitleLabel ──────────────────────────────────────────
	# In the Inspector set:
	#   Text          →  CIRCUIT BREAKER
	#   Font Size     →  88
	#   Align         →  Center
	#   Anchor        →  Center Top
	#   Position      →  (-320, 140)    (so it sits centre-screen)
	#   Size          →  (640, 120)
	#   Font Color    →  #F5EFE0  (bright cream)
	# Shadow:
	#   shadow_color  →  #E22020
	#   shadow_offset →  (4, 4)

	# ── WarnLabel ───────────────────────────────────────────
	# In the Inspector set:
	#   Text      →  !! OVERLOAD DETECTED !!
	#   Font Size →  18
	#   Align     →  Center
	#   Position  →  (-240, 280)
	#   Size      →  (480, 32)
	#   Color     →  #E22020

	# ── StartButton ─────────────────────────────────────────
	# In the Inspector set:
	#   Text      →  [ START ]
	#   Font Size →  24
	#   Position  →  (-110, 360)
	#   Size      →  (220, 52)
	#   (remove default background in Theme Overrides → Styles → set all to StyleBoxEmpty)

	# ── QuitButton ──────────────────────────────────────────
	# In the Inspector set:
	#   Text      →  [ QUIT ]
	#   Font Size →  20
	#   Position  →  (-90, 430)
	#   Size      →  (180, 44)

	start_button.pressed.connect(_on_start)
	quit_button.pressed.connect(_on_quit)
	how_button.pressed.connect(_on_how)
	start_button.pressed.connect(_on_click_sound)
	quit_button.pressed.connect(_on_click_sound)
	how_button.pressed.connect(_on_click_sound)

	
func _process(delta: float) -> void:
	# Random flicker on the warning label
	_flicker_time += delta
	if _flicker_time >= _next_flick:
		_flicker_time = 0.0
		_next_flick = randf_range(0.5, 2.0)
		warn_label.visible = !warn_label.visible

func _on_click_sound() -> void:
	if click_player and click_player.is_inside_tree():
		click_player.play()
		
func _on_start() -> void:
	click_player.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/GameScreen.tscn")

func _on_how() -> void:
	click_player.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")

func _on_quit() -> void:
	click_player.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()
	get_tree().quit()
