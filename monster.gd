extends Node2D

## Reprezentuje potwora — zarządza HP, wyświetlaniem obrażeń i efektami.

@export var max_hp: int = 10

var hp: int = 10

@onready var _main: Node2D = $"../.."
@onready var _name_label: Label = $NameLabel
@onready var _hp_bar: ColorRect = $HPBar
@onready var _hp_fill: ColorRect = $HPBar/HPFill
@onready var _damage_label: Label = $DamageLabel
@onready var _crit_label: Label = $CritLabel


func _ready() -> void:
	hp = max_hp
	_update_hp()
	_damage_label.visible = false
	_crit_label.visible = false


func take_damage(amount: int) -> void:
	hp = max(hp - amount, 0)
	_update_hp()
	SoundManager.play_monster_hit()
	_show_damage(amount)
	_shake()
	if hp <= 0:
		_die()


func show_crit_label() -> void:
	_crit_label.visible = true
	await get_tree().create_timer(1.0).timeout
	_crit_label.visible = false


func attack_player() -> void:
	_main.take_damage_from_monster(1)


# ---------------------------------------------------------------------------
# Private
# ---------------------------------------------------------------------------

func _show_damage(amount: int) -> void:
	_damage_label.text = "-%d" % amount
	_damage_label.visible = true
	await get_tree().create_timer(0.6).timeout
	_damage_label.visible = false


func _shake() -> void:
	var orig_x: float = position.x
	for _i in range(3):
		position.x = orig_x + 4.0
		await get_tree().create_timer(0.03).timeout
		position.x = orig_x - 4.0
		await get_tree().create_timer(0.03).timeout
	position.x = orig_x


func _die() -> void:
	SoundManager.play_monster_die()
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.4)
	await tween.finished
	_main.spawn_new_monster()
	queue_free()


func _update_hp() -> void:
	var ratio: float = float(hp) / float(max_hp)
	_hp_fill.size.x = _hp_bar.size.x * ratio
	if ratio > 0.6:
		_hp_fill.color = Color(0.2, 1.0, 0.2, 1)
	elif ratio > 0.3:
		_hp_fill.color = Color(1.0, 0.8, 0.2, 1)
	else:
		_hp_fill.color = Color(1.0, 0.2, 0.2, 1)
