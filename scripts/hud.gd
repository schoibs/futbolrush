extends CanvasLayer

signal play_pressed
signal restart_pressed

@onready var start_screen: Control = $Root/StartScreen
@onready var score_label: Label = $Root/ScoreLabel
@onready var game_over_screen: Control = $Root/GameOverScreen
@onready var final_score_label: Label = $Root/GameOverScreen/GameOverBox/FinalScoreLabel
@onready var play_button: Button = $Root/StartScreen/MenuBox/PlayButton
@onready var restart_button: Button = $Root/GameOverScreen/GameOverBox/RestartButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)

func show_start() -> void:
	start_screen.visible = true
	score_label.visible = false
	game_over_screen.visible = false

func show_playing(score: int) -> void:
	start_screen.visible = false
	score_label.visible = true
	game_over_screen.visible = false
	set_score(score)

func show_game_over(final_score: int) -> void:
	start_screen.visible = false
	score_label.visible = false
	game_over_screen.visible = true
	final_score_label.text = "Final Score: %d" % final_score

func set_score(score: int) -> void:
	score_label.text = "Score: %d" % score

func _on_play_button_pressed() -> void:
	play_pressed.emit()

func _on_restart_button_pressed() -> void:
	restart_pressed.emit()
