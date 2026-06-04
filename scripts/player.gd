extends Area2D

signal died
signal shoot_requested(direction: Vector2)

@export var max_speed := 520.0
@export var acceleration := 1800.0
@export var friction := 2200.0
@export var half_width := 28.0

@export_group("Aim")
@export var aim_min_degrees := -35.0
@export var aim_max_degrees := 35.0
@export var aim_sweep_speed := 110.0
@export var aim_length := 95.0

@onready var player_animation: AnimatedSprite2D = $PlayerAnimation
@onready var aim_indicator: Node2D = $AimIndicator
@onready var aim_line: Line2D = $AimIndicator/AimLine
@onready var aim_arrow_head: Polygon2D = $AimIndicator/AimArrowHead

var velocity_x := 0.0
var current_aim_degrees := 0.0
var aim_sweep_direction := 1.0

func _ready() -> void:
	add_to_group("player")
	
	if player_animation.sprite_frames != null and player_animation.sprite_frames.has_animation("dribble"):
		player_animation.play("dribble")
	
	reset_aim()
	set_aim_active(false)

func _physics_process(delta: float) -> void:
	update_movement(delta)
	update_aim(delta)
	handle_shoot_input()
	
func update_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0.0:
		var target_speed := direction * max_speed
		velocity_x = move_toward(velocity_x, target_speed, acceleration * delta)
	else:
		velocity_x = move_toward(velocity_x, 0.0, friction * delta)

	position.x += velocity_x * delta

	var viewport_width := get_viewport_rect().size.x
	position.x = clampf(position.x, half_width, viewport_width - half_width)

func update_aim(delta: float) -> void:
	current_aim_degrees += aim_sweep_direction * aim_sweep_speed * delta

	if current_aim_degrees >= aim_max_degrees:
		current_aim_degrees = aim_max_degrees
		aim_sweep_direction = -1.0
	elif current_aim_degrees <= aim_min_degrees:
		current_aim_degrees = aim_min_degrees
		aim_sweep_direction = 1.0

	update_aim_visual()
	
func update_aim_visual() -> void:
	aim_indicator.rotation_degrees = current_aim_degrees
	aim_line.points = PackedVector2Array([
		Vector2.ZERO,
		Vector2(0.0, -aim_length),
	])
	aim_arrow_head.position = Vector2(0.0, -aim_length)
	aim_arrow_head.polygon = PackedVector2Array([
		Vector2(0.0, -14.0),
		Vector2(-9.0, 7.0),
		Vector2(9.0, 7.0),
	])
	
func get_aim_direction() -> Vector2:
	var radians := deg_to_rad(current_aim_degrees)
	return Vector2(sin(radians), -cos(radians)).normalized()
	
func handle_shoot_input() -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot_requested.emit(get_aim_direction())

func reset_aim() -> void:
	current_aim_degrees = 0.0
	aim_sweep_direction = 1.0
	update_aim_visual()

func set_aim_active(active: bool) -> void:
	aim_indicator.visible = active
