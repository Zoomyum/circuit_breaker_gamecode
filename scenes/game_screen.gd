extends Control

# res://scripts/GameScreen.gd

@onready var timer_label : Label         = $TimerLabel
@onready var node_grid   : GridContainer = $NodeGrid
@onready var click_player : AudioStreamPlayer = $ClickPlayer

var nodes        : Array = []
var time_elapsed : float = 0.0
var escalate_timer : float = 0.0
var game_over    : bool  = false

var routing_active : bool  = false
var routing_from   : int   = -1
var routing_amount : float = 0.0

const NODE_NAMES := ["REACTOR CORE","COOLANT PUMP","BLAST SHIELD","POWER GRID","EXHAUST VENT","BUFFER TANK"]
const FILL_RATES := [10.0, 3.0, 3.0, 5.0, 2.0, 0.0]


func _ready() -> void:
	for child in node_grid.get_children():
		nodes.append(child)

	for node in nodes:
		node.clicked.connect(_on_node_clicked)
		node.exploded.connect(_on_node_exploded)

	nodes[0].neighbours = [1, 2, 3, 4, 5]
	nodes[1].neighbours = [0, 3, 4, 5]
	nodes[2].neighbours = [3, 4]
	nodes[3].neighbours = [1, 2, 4, 5]
	nodes[4].neighbours = [0, 1, 2, 3, 5]
	nodes[5].neighbours = [1, 3, 4]

	for i in range(nodes.size()):
		nodes[i].fill_rate = FILL_RATES[i]

	nodes[4].cooldown_max = 8.0


func _process(delta: float) -> void:
	if game_over:
		return

	time_elapsed += delta
	var mins := int(time_elapsed / 60)
	var secs := int(time_elapsed) % 60
	timer_label.text = "%02d:%02d" % [mins, secs]

	# Invisibly creep up fill rates every 30s
	escalate_timer += delta
	if escalate_timer >= 30.0:
		escalate_timer = 0.0
		for node in nodes:
			node.fill_rate *= 1.1


func _on_node_clicked(node_id: int) -> void:
	click_player.play()
	if game_over:
		return

	if not routing_active:
		var clicked_node = nodes[node_id]
		if clicked_node.on_cooldown or clicked_node._exploded:
			return
		if clicked_node.pressure <= 5.0:
			return


		# Exhaust vents instantly — no routing needed
		if node_id == 4:
			clicked_node.pressure = 0.0
			clicked_node.pressure_bar.value = 0.0
			clicked_node.on_cooldown = true
			clicked_node.cooldown_time = clicked_node.cooldown_max
			return
		routing_active = true
		routing_from   = node_id
		routing_amount = clicked_node.pressure
		clicked_node.pressure = 0.0
		clicked_node.pressure_bar.value = 0.0
		clicked_node.set_selected(true)

		for id in clicked_node.neighbours:
			nodes[id].set_routing_target(true)

	else:
		if node_id in nodes[routing_from].neighbours:
			nodes[node_id].receive_pressure(routing_amount)
			_cancel_routing()
		elif node_id == routing_from:
			nodes[routing_from].pressure = routing_amount
			_cancel_routing()


func _cancel_routing() -> void:
	if routing_from != -1:
		nodes[routing_from].set_selected(false)
		for i in range(nodes.size()):
			nodes[i].set_routing_target(false)
	routing_active = false
	routing_from   = -1
	routing_amount = 0.0


func _on_node_exploded(node_id: int) -> void:
	game_over = true
	_cancel_routing()
	await get_tree().create_timer(1.2).timeout
	var go_scene = load("res://scenes/GameOver.tscn").instantiate()
	go_scene.set_meta("exploded_node", NODE_NAMES[node_id])
	go_scene.set_meta("time_text", timer_label.text)
	get_tree().root.add_child(go_scene)
	get_tree().current_scene = go_scene
	queue_free()
