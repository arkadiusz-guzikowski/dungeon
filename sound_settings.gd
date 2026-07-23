extends Node

## Ustawienia głośności dźwięków — node w agent.tscn.
## Wartości są przekazywane do SoundManager (autoload) przy starcie.

@export var menu_music_volume: float = -8.0
@export var game_music_volume: float = -8.0
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


func _ready() -> void:
	SoundManager.menu_music_volume_db = menu_music_volume
	SoundManager.game_music_volume_db = game_music_volume
	SoundManager.hit_volume = hit_volume
	SoundManager.crit_hit_volume = crit_hit_volume
	SoundManager.miss_volume = miss_volume
	SoundManager.player_hurt_volume = player_hurt_volume
	SoundManager.game_over_volume = game_over_volume
	SoundManager.swing_volume = swing_volume
	SoundManager.monster_hit_volume = monster_hit_volume
	SoundManager.monster_die_volume = monster_die_volume
	SoundManager.monster_attack_volume = monster_attack_volume
	SoundManager.zombie_spawn_volume = zombie_spawn_volume
