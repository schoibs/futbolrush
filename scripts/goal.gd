extends Area2D

signal ball_entered(ball: Area2D)

func _ready() -> void:
	add_to_group("goal")
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ball"):
		ball_entered.emit(area)
