extends CanvasLayer

signal play_pressed
signal restart_pressed

@onready var start_screen: Control = $Root/StartScreen
@onready var score_label: Label = $Root/ScoreLabel
@onready var game_over_screen: Control = $Root/GameOverScreen
@onready var final_score_label: Label = $Root/GameOverScreen/GameOverBox/FinalScoreLabel
@onready var play_button: Button = $Root/StartScreen/MenuBox/PlayButton
@onready var restart_button: Button = $Root/GameOverScreen/GameOverBox/RestartButton
@onready var impact_flash: ColorRect = $Root/ImpactFlash
@onready var button_sound: AudioStreamPlayer = $ButtonSound
@onready var collision_sound: AudioStreamPlayer = $CollisionSound
@onready var start_best_score_label: Label = $Root/StartScreen/MenuBox/BestScoreLabel
@onready var game_over_best_score_label: Label = $Root/GameOverScreen/GameOverBox/GameOverBestScoreLabel


func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)

func show_start(best_score: int = 0) -> void:
	start_screen.visible = true
	score_label.visible = false
	game_over_screen.visible = false
	start_best_score_label.text = "Best: %d" % best_score
	start_best_score_label.visible = best_score > 0

func show_playing(score: int) -> void:
	start_screen.visible = false
	score_label.visible = true
	game_over_screen.visible = false
	set_score(score)

func show_game_over(final_score: int, best_score: int = 0) -> void:
	start_screen.visible = false
	score_label.visible = false
	game_over_screen.visible = true
	final_score_label.text = "Final Score: %d" % final_score
	game_over_best_score_label.text = "Best: %d" % best_score

func set_score(score: int) -> void:
	score_label.text = "Score: %d" % score

func play_impact_feedback() -> void:
	impact_flash.visible = true
	impact_flash.modulate.a = 0.65

	var tween := create_tween()
	tween.tween_property(impact_flash, "modulate:a", 0.0, 0.18)
	tween.finished.connect(func(): impact_flash.visible = false)

func _on_play_button_pressed() -> void:
	play_button_sound()
	play_pressed.emit()

func _on_restart_button_pressed() -> void:
	play_button_sound()
	restart_pressed.emit()
	
func play_button_sound() -> void:
	if button_sound.stream != null:
		button_sound.play()

func play_collision_feedback() -> void:
	if collision_sound.stream != null:
		collision_sound.play()

	play_impact_feedback()
