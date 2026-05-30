extends Area2D

signal died

@export var max_speed := 520.0
@export var acceleration := 1800.0
@export var friction := 2200.0
@export var half_width := 28.0

var velocity_x := 0.0

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0.0:
		var target_speed := direction * max_speed
		velocity_x = move_toward(velocity_x, target_speed, acceleration * delta)
	else:
		velocity_x = move_toward(velocity_x, 0.0, friction * delta)

	position.x += velocity_x * delta

	var viewport_width := get_viewport_rect().size.x
	position.x = clampf(position.x, half_width, viewport_width - half_width)
