extends Node2D

enum GameState { START, PLAYING, GAME_OVER }

@export var defender_scene: PackedScene
@export var defender_speed := 300.0
@export var defender_half_width := 30.0
@export var defender_start_y := -50.0

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
	spawn_timer.start()
	score_timer.start()

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
	var defender = defender_scene.instantiate()
	defender.speed = defender_speed

	var viewport_width := get_viewport_rect().size.x
	var spawn_x := randf_range(defender_half_width, viewport_width - defender_half_width)
	defender.position = Vector2(spawn_x, defender_start_y)

	defender.hit_player.connect(_on_defender_hit_player)
	defender_container.add_child(defender)

func _on_spawn_timer_timeout() -> void:
	if game_state != GameState.PLAYING:
		return

	spawn_defender()

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
