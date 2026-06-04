extends Area2D

signal missed

enum BallState { READY, IN_FLIGHT }

@export_group("Bounce")

@export var ready_offset := Vector2(0.0, -52.0)
@export var shot_speed := 900.0
@export var offscreen_margin := 80.0
@export var reset_delay := 0.25
@export var ball_radius := 14.0
@export var show_while_ready := false

@export var bounce_damping := 0.92
@export var min_bounce_speed := 650.0
@export var bounce_separation := 8.0
@export var bounce_cooldown := 0.08

var state := BallState.READY
var velocity := Vector2.ZERO
var player: Node2D
var reset_pending := false
var reset_time_remaining := 0.0
var bounce_cooldown_remaining := 0.0

func _ready() -> void:
	add_to_group("ball")
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	queue_redraw()

func setup(follow_player: Node2D) -> void:
	player = follow_player
	reset_to_ready()

func _physics_process(delta: float) -> void:
	update_bounce_cooldown(delta)

	if reset_pending:
		reset_time_remaining -= delta
		if reset_time_remaining <= 0.0:
			reset_to_ready()
		return

	if state == BallState.READY:
		follow_player()
	elif state == BallState.IN_FLIGHT:
		global_position += velocity * delta

		if is_offscreen():
			miss()

func _draw() -> void:
#	draw instead of using a sprite
	draw_circle(Vector2.ZERO, ball_radius, Color.WHITE)
	draw_arc(Vector2.ZERO, ball_radius, 0.0, TAU, 32, Color.BLACK, 2.0)
	draw_circle(Vector2.ZERO, ball_radius * 0.35, Color.BLACK)

func follow_player() -> void:
	if player == null:
		return

	global_position = player.global_position + ready_offset

func launch(direction: Vector2) -> void:
	if not is_ready():
		return

	if direction == Vector2.ZERO:
		return

	state = BallState.IN_FLIGHT
	velocity = direction.normalized() * shot_speed
	visible = true

func handle_goal() -> void:
	if not is_in_flight():
		return

	schedule_reset()

func miss() -> void:
	if not is_in_flight():
		return

	missed.emit()
	schedule_reset()

func reset_to_ready() -> void:
	state = BallState.READY
	velocity = Vector2.ZERO
	reset_pending = false
	reset_time_remaining = 0.0
	follow_player()
	visible = show_while_ready

func schedule_reset() -> void:
	state = BallState.READY
	velocity = Vector2.ZERO
	reset_pending = true
	reset_time_remaining = reset_delay
	visible = false

func is_ready() -> bool:
	add_to_group("ball")

	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

	queue_redraw()
	return state == BallState.READY and not reset_pending

func is_in_flight() -> bool:
	return state == BallState.IN_FLIGHT and not reset_pending

func is_offscreen() -> bool:
	var viewport_size := get_viewport_rect().size

	return (
		global_position.x < -offscreen_margin
		or global_position.x > viewport_size.x + offscreen_margin
		or global_position.y < -offscreen_margin
		or global_position.y > viewport_size.y + offscreen_margin
	)
	
func update_bounce_cooldown(delta: float) -> void:
	if bounce_cooldown_remaining <= 0.0:
		return

	bounce_cooldown_remaining = maxf(bounce_cooldown_remaining - delta, 0.0)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("defender"):
		bounce_from_defender(area)

func bounce_from_defender(defender: Area2D) -> void:
	if not is_in_flight():
		return

	if bounce_cooldown_remaining > 0.0:
		return

	if velocity == Vector2.ZERO:
		return

	var normal := (global_position - defender.global_position).normalized()
	if normal == Vector2.ZERO:
		normal = -velocity.normalized()

	velocity = velocity.bounce(normal) * bounce_damping

	if velocity.length() < min_bounce_speed:
		velocity = velocity.normalized() * min_bounce_speed

	global_position += normal * bounce_separation
	bounce_cooldown_remaining = bounce_cooldown
