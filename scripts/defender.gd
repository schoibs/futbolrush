extends Area2D

signal hit_player

@export var speed := 300.0
@export var half_height := 38.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position.y += speed * delta

	var viewport_height := get_viewport_rect().size.y
	if position.y - half_height > viewport_height:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		hit_player.emit()
