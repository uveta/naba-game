extends Node
## Global game state (autoload). Holds score and lives and broadcasts changes.

signal score_changed(score: int)
signal lives_changed(lives: int)
signal game_over

const START_LIVES: int = 3

var score: int = 0
var lives: int = START_LIVES
var is_game_over: bool = false


func reset() -> void:
	score = 0
	lives = START_LIVES
	is_game_over = false
	score_changed.emit(score)
	lives_changed.emit(lives)


func add_score(points: int) -> void:
	if is_game_over:
		return
	score += points
	score_changed.emit(score)


func lose_life() -> void:
	if is_game_over:
		return
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		is_game_over = true
		game_over.emit()
