extends Node2D

@export var defender_scene: PackedScene
@export var defender_speed := 300.0
@export var defender_half_width := 30.0
@export var defender_start_y := -50.0

@onready var defender_container: Node2D = $DefenderContainer
@onready var spawn_timer: Timer = $SpawnTimer
@onready var player: Area2D = $Player

var is_game_over := false

func _ready() -> void:
	randomize()
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	if is_game_over:
		return

	spawn_defender()

func spawn_defender() -> void:
	var defender = defender_scene.instantiate()
	defender.speed = defender_speed

	var viewport_width := get_viewport_rect().size.x
	var spawn_x := randf_range(defender_half_width, viewport_width - defender_half_width)
	defender.position = Vector2(spawn_x, defender_start_y)

	defender.hit_player.connect(_on_defender_hit_player)
	defender_container.add_child(defender)

func _on_defender_hit_player() -> void:
	if is_game_over:
		return

	is_game_over = true
	spawn_timer.stop()
	player.set_physics_process(false)
	print("Game Over")
