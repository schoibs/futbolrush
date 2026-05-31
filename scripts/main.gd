extends Node2D

enum GameState { START, PLAYING, GAME_OVER }

@export_group("Difficulty")
@export var intro_spawn_interval := 1.20
@export var mid_spawn_interval := 0.85
@export var late_spawn_interval := 0.55
@export var intro_speed_range := Vector2(260.0, 320.0)
@export var mid_speed_range := Vector2(330.0, 430.0)
@export var late_speed_range := Vector2(430.0, 560.0)
@export var intro_grace_seconds := 10
@export var safe_intro_gap := 140.0

@export var defender_scene: PackedScene
@export var defender_speed := 300.0
@export var defender_half_width := 30.0
@export var defender_start_y := -50.0

@export var sprinter_defender_scene: PackedScene
@export var sprinter_chance := 0.20
@export var sprinter_speed_bonus := 120.0

@onready var defender_container: Node2D = $DefenderContainer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var score_timer: Timer = $ScoreTimer
@onready var player: Area2D = $Player
@onready var hud = $HUD

var game_state := GameState.START
var score := 0
var player_start_position := Vector2.ZERO

func _ready() -> void:
	randomize()
	spawn_timer.one_shot = true
	player_start_position = player.position

	if not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	if not score_timer.timeout.is_connected(_on_score_timer_timeout):
		score_timer.timeout.connect(_on_score_timer_timeout)

	if not hud.play_pressed.is_connected(_on_hud_play_pressed):
		hud.play_pressed.connect(_on_hud_play_pressed)

	if not hud.restart_pressed.is_connected(_on_hud_restart_pressed):
		hud.restart_pressed.connect(_on_hud_restart_pressed)

	enter_start_state()

func enter_start_state() -> void:
	game_state = GameState.START
	score = 0
	spawn_timer.stop()
	score_timer.stop()
	clear_defenders()
	reset_player()
	player.set_physics_process(false)
	hud.show_start()

func start_run() -> void:
	game_state = GameState.PLAYING
	score = 0
	clear_defenders()
	reset_player()
	player.set_physics_process(true)
	hud.show_playing(score)
	start_spawn_timer()
	score_timer.start()

func start_spawn_timer() -> void:
	spawn_timer.wait_time = get_current_spawn_interval()
	spawn_timer.start()

func enter_game_over_state() -> void:
	if game_state == GameState.GAME_OVER:
		return

	game_state = GameState.GAME_OVER
	spawn_timer.stop()
	score_timer.stop()
	player.set_physics_process(false)
	clear_defenders()
	hud.show_game_over(score)

func reset_player() -> void:
	player.position = player_start_position

func clear_defenders() -> void:
	for defender in defender_container.get_children():
		defender.queue_free()

func spawn_defender() -> void:
	var chosen_scene := choose_defender_scene()
	var defender = chosen_scene.instantiate()
	defender.speed = get_current_defender_speed()
	
	if chosen_scene == sprinter_defender_scene:
		defender.speed += sprinter_speed_bonus
	
	var viewport_width := get_viewport_rect().size.x
	var spawn_x := get_spawn_x()
	defender.position = Vector2(spawn_x, defender_start_y)

	defender.hit_player.connect(_on_defender_hit_player)
	defender_container.add_child(defender)

func get_current_spawn_interval() -> float:
	if score < 20:
		return intro_spawn_interval
	if score < 45:
		return mid_spawn_interval
	return late_spawn_interval

func get_current_speed_range() -> Vector2:
	if score < 20:
		return intro_speed_range
	if score < 45:
		return mid_speed_range
	return late_speed_range

func get_current_defender_speed() -> float:
	var speed_range := get_current_speed_range()
	return randf_range(speed_range.x, speed_range.y)

func get_spawn_x() -> float:
	var viewport_width := get_viewport_rect().size.x
	var min_x := defender_half_width
	var max_x := viewport_width - defender_half_width

	for attempt in range(8):
#		try up to 8 random positions and use first one that seems fair
		var candidate := randf_range(min_x, max_x)
		var far_enough_from_player := absf(candidate - player.position.x) >= safe_intro_gap

		if score >= intro_grace_seconds or far_enough_from_player:
			return candidate

	return randf_range(min_x, max_x)

func choose_defender_scene() -> PackedScene:
	if score >= 20 and sprinter_defender_scene != null and randf() < sprinter_chance:
		return sprinter_defender_scene

	return defender_scene

func _on_spawn_timer_timeout() -> void:
	if game_state != GameState.PLAYING:
		return

	spawn_defender()
	start_spawn_timer()

func _on_score_timer_timeout() -> void:
	if game_state != GameState.PLAYING:
		return

	score += 1
	hud.set_score(score)

func _on_defender_hit_player() -> void:
	enter_game_over_state()

func _on_hud_play_pressed() -> void:
	start_run()

func _on_hud_restart_pressed() -> void:
	start_run()
