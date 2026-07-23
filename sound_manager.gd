extends Node

## Globalny manager dźwięków — autoload.
## Dwa niezależne kanały SFX: gracz i potwór + osobny kanał muzyki.

var _player_player: AudioStreamPlayer2D
var _monster_player: AudioStreamPlayer2D
var _music_player: AudioStreamPlayer2D

var _trafienie: AudioStream
var _zombie_spawn: AudioStream
var _menu_music: AudioStream
var _game_music: AudioStream

# Głośność poszczególnych dźwięków (do ustawienia w Inspektorze)
@export var hit_volume: float = -3.0
@export var crit_hit_volume: float = 3.0
@export var miss_volume: float = -2.0
@export var player_hurt_volume: float = -2.0
@export var game_over_volume: float = -1.0
@export var swing_volume: float = -6.0
@export var monster_hit_volume: float = -4.0
@export var monster_die_volume: float = -2.0
@export var monster_attack_volume: float = -2.0
@export var zombie_spawn_volume: float = 3.0

# Globalna głośność SFX
var sfx_volume_db: float = 0.0:
	set(value):
		sfx_volume_db = value

# Osobne głośności dla muzyki menu i gry
var menu_music_volume_db: float = -8.0
var game_music_volume_db: float = -8.0


func _ready() -> void:
	_zombie_spawn = load("res://sounds/dragon-studio-zombie-sound-357975.wav")
	_trafienie = load("res://sounds/trafienie.wav")
	_menu_music = load("res://sounds/Lochy Zamek.mp3")
	_game_music = load("res://sounds/Zimne Lochy.mp3")

	_player_player = AudioStreamPlayer2D.new()
	add_child(_player_player)
	_monster_player = AudioStreamPlayer2D.new()
	add_child(_monster_player)
	_music_player = AudioStreamPlayer2D.new()
	add_child(_music_player)
	_music_player.finished.connect(_on_music_finished)


func play_menu_music() -> void:
	_play_music(_menu_music, menu_music_volume_db)


func play_game_music() -> void:
	_play_music(_game_music, game_music_volume_db)


func _play_music(stream: AudioStream, volume: float) -> void:
	if stream == null:
		return
	_music_player.stream = stream
	_music_player.volume_db = volume
	_music_player.play()


func _on_music_finished() -> void:
	_music_player.play()


func toggle_music() -> void:
	if _music_player.playing:
		_music_player.stop()
	else:
		_music_player.play()


func is_music_playing() -> bool:
	return _music_player.playing


func set_menu_music_volume(value: float) -> void:
	menu_music_volume_db = value
	if _music_player.playing and _music_player.stream == _menu_music:
		_music_player.volume_db = value


func set_game_music_volume(value: float) -> void:
	game_music_volume_db = value
	if _music_player.playing and _music_player.stream == _game_music:
		_music_player.volume_db = value


func get_menu_music_volume() -> float:
	return menu_music_volume_db


func get_game_music_volume() -> float:
	return game_music_volume_db


func set_sfx_volume(value: float) -> void:
	sfx_volume_db = value


func get_sfx_volume() -> float:
	return sfx_volume_db


func play_hit() -> void: _play(_player_player, _trafienie, hit_volume)
func play_crit_hit() -> void: _play(_player_player, _trafienie, crit_hit_volume)
func play_miss() -> void: _play(_player_player, _trafienie, miss_volume)
func play_player_hurt() -> void: _play(_player_player, _trafienie, player_hurt_volume)
func play_game_over() -> void: _play(_player_player, _trafienie, game_over_volume)
func play_swing() -> void: _play(_player_player, _trafienie, swing_volume)

func play_monster_hit() -> void: _play(_monster_player, _zombie_spawn, monster_hit_volume)
func play_monster_die() -> void: _play(_monster_player, _zombie_spawn, monster_die_volume)
func play_monster_attack() -> void: _play(_monster_player, _zombie_spawn, monster_attack_volume)
func play_zombie_spawn() -> void: _play(_monster_player, _zombie_spawn, zombie_spawn_volume)


func _play(player: AudioStreamPlayer2D, stream: AudioStream, volume: float) -> void:
	if stream == null:
		return
	player.stream = stream
	player.volume_db = volume + sfx_volume_db
	player.play()
