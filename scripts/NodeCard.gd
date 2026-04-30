extends PanelContainer

# res://scripts/NodeCard.gd

@onready var pressure_bar : ProgressBar = $MarginContainer/VBoxContainer/PressureBar
@onready var pct_label    : Label       = $MarginContainer/VBoxContainer/HBoxContainer/PctLabel
@onready var crit_label   : Label       = $MarginContainer/VBoxContainer/HBoxContainer/CritLabel
@onready var warn_player : AudioStreamPlayer = null
var cooldown_label : Label = null

@export var fill_rate    : float = 0.0
@export var node_id      : int   = 0
@export var neighbours   : Array = []
@export var cooldown_max : float = 0.0

var pressure      : float = 0.0
var on_cooldown   : bool  = false
var cooldown_time : float = 0.0
var _crit_flash   : float = 0.0
var _exploded     : bool  = false
var _is_selected  : bool  = false
var _is_target    : bool  = false
var _base_style   : StyleBoxFlat = null

signal clicked(node_id)
signal exploded(node_id)


func _ready() -> void:
	warn_player = get_node_or_null("WarnPlayer")
	crit_label.visible = false
	pressure_bar.value = 0.0
	pct_label.text     = "0%"

	# Only exists on Exhaust node
	cooldown_label = get_node_or_null("MarginContainer/VBoxContainer/CooldownLabel")
	if cooldown_label:
		cooldown_label.text = ""

	_base_style = get_theme_stylebox("panel").duplicate()

	mouse_entered.connect(_on_hover_enter)
	mouse_exited.connect(_on_hover_exit)
	gui_input.connect(_on_input)


func _process(delta: float) -> void:
	if _exploded:
		return

	pressure += fill_rate * delta
	pressure = clamp(pressure, 0.0, 100.0)
	pressure_bar.value = pressure
	pct_label.text = str(int(pressure)) + "%"

	if on_cooldown:
		cooldown_time -= delta
		if cooldown_time <= 0.0:
			on_cooldown   = false
			cooldown_time = 0.0
		if cooldown_label:
			cooldown_label.text = "CD " + str(int(cooldown_time) + 1) + "s"
	else:
		if cooldown_label:
			cooldown_label.text = ""

	# Critical flash at 90%+
	if pressure >= 90.0:
		_crit_flash += delta
		if _crit_flash >= 0.15:
			_crit_flash        = 0.0
			crit_label.visible = !crit_label.visible
			if crit_label.visible:
				if warn_player and not warn_player.playing:
					warn_player.play()

	else:
		crit_label.visible = false
		_crit_flash        = 0.0
		if warn_player:
			warn_player.stop()
		

	# Explode at 100%
	if pressure >= 100.0:
		_exploded          = true
		crit_label.text    = "!! EXPLODED !!"
		crit_label.visible = true
		emit_signal("exploded", node_id)


func _on_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("clicked", node_id)


func _on_hover_enter() -> void:
	if _is_target:
		_set_border(Color(1.0, 0.95, 0.2), 4)


func _on_hover_exit() -> void:
	if _is_target:
		_set_border(Color(0.8, 0.75, 0.1), 3)
	elif _is_selected:
		_set_border(Color(0.9, 0.2, 0.2), 3)
	else:
		_restore_border()


func set_selected(enabled: bool) -> void:
	_is_selected = enabled
	if enabled:
		_set_border(Color(0.9, 0.2, 0.2), 3)
	else:
		_restore_border()


func set_routing_target(enabled: bool) -> void:
	_is_target = enabled
	if enabled:
		_set_border(Color(0.8, 0.75, 0.1), 3)
	else:
		_restore_border()


func _set_border(color: Color, _width: int) -> void:
	var style := _base_style.duplicate()
	style.bg_color = color.darkened(0.6)
	add_theme_stylebox_override("panel", style)


func _restore_border() -> void:
	add_theme_stylebox_override("panel", _base_style)


func receive_pressure(amount: float) -> void:
	pressure += amount
	pressure = clamp(pressure, 0.0, 100.0)
