extends Node2D

@onready var pitch_sprite: Sprite2D = $PitchSprite

var last_viewport_size := Vector2.ZERO

func _ready() -> void:
	fit_pitch_to_viewport()

func _process(_delta: float) -> void:
	var current_size := get_viewport_rect().size
	if current_size != last_viewport_size:
		fit_pitch_to_viewport()

func fit_pitch_to_viewport() -> void:
	if pitch_sprite.texture == null:
		return

	var size := get_viewport_rect().size
	var texture_size := pitch_sprite.texture.get_size()

	last_viewport_size = size
	pitch_sprite.centered = false
	pitch_sprite.position = Vector2.ZERO
	pitch_sprite.scale = Vector2(size.x / texture_size.x, size.y / texture_size.y)
