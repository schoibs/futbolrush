extends Area2D

signal hit_player

@export var speed := 300.0
@export var half_height := 38.0

@onready var run_animation: AnimatedSprite2D = $RunAnimation

func _ready() -> void:
	add_to_group("defender")
	area_entered.connect(_on_area_entered)
	
	if run_animation.sprite_frames != null and run_animation.sprite_frames.has_animation("run"):
		run_animation.play("run")

func _physics_process(delta: float) -> void:
	position.y += speed * delta

	var viewport_height := get_viewport_rect().size.y
	if position.y - half_height > viewport_height:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		hit_player.emit()
