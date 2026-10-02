extends CanvasLayer
## Displays score, lives and the game-over message.

@onready var score_label: Label = $ScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var game_over_label: Label = $GameOverLabel


func _ready() -> void:
	GameState.score_changed.connect(_on_score_changed)
	GameState.lives_changed.connect(_on_lives_changed)
	GameState.game_over.connect(_on_game_over)
	_on_score_changed(GameState.score)
	_on_lives_changed(GameState.lives)
	game_over_label.visible = false


func _on_score_changed(score: int) -> void:
	score_label.text = "Score: %d" % score


func _on_lives_changed(lives: int) -> void:
	lives_label.text = "Lives: %d" % lives


func _on_game_over() -> void:
	game_over_label.visible = true
