extends Node2D

## Główny kontroler gry — zarządza stanem, potworami i mechaniką skill checka.

enum State { IDLE, SWINGING, CHECKING }

@onready var _skill_check_area: Node2D = $SkillCheckArea
@onready var _arm_pivot: Node2D = $SkillCheckArea/Base/ArmPivot
@onready var _monster_container: Node2D = $MonsterContainer
@onready var _hearts_label: Label = $UI/HeartsLabel
@onready var _monster_scene = preload("res://monster.tscn")

@export_range(0.1, 5.0, 0.1) var swing_speed: float = 1.0
@export_range(10.0, 180.0, 1.0) var swing_range: float = 90.0
@export_range(50.0, 300.0, 1.0) var circle_radius: float = 120.0
@export_range(5.0, 60.0, 1.0) var target_size: float = 20.0
@export_range(2.0, 30.0, 1.0) var critical_size: float = 5.0
@export_range(0.01, 0.5, 0.01) var smoothness: float = 0.08

var state: int = State.IDLE
var feedback_color: Color = Color.TRANSPARENT
var feedback_timer: float = 0.0
var feedback_duration: float = 0.4
var target_center: float = 0.0
var target_active: bool = false
var snapshot_angle: float = 0.0
var player_hp: int = 3
var max_player_hp: int = 3
var current_monster: Node2D = null
var monster_can_attack: bool = false

var _time: float = 0.0
var _speed_multiplier: float = 1.0


func _ready() -> void:
	randomize()
	_arm_pivot.rotation = 0.0
	_update_hearts()
	spawn_new_monster()
	SoundManager.play_game_music()


func _process(delta: float) -> void:
	_handle_input()
	_update_arm(delta)
	_update_feedback(delta)


# ---------------------------------------------------------------------------
# Input
# ---------------------------------------------------------------------------

func _handle_input() -> void:
	if not Input.is_action_just_pressed("ui_accept"):
		return
	match state:
		State.IDLE:
			if player_hp > 0:
				_start_round()
		State.SWINGING:
			snapshot_angle = _arm_pivot.rotation
			state = State.CHECKING
			_check_hit()
		State.CHECKING:
			_start_round()


# ---------------------------------------------------------------------------
# Round lifecycle
# ---------------------------------------------------------------------------

func _start_round() -> void:
	_time = 0.0
	_speed_multiplier = 0.0
	_arm_pivot.rotation = 0.0
	feedback_color = Color.TRANSPARENT
	feedback_timer = 0.0
	target_center = randf_range(deg_to_rad(-80), deg_to_rad(80))
	target_active = true
	state = State.SWINGING
	SoundManager.play_swing()
	_skill_check_area.queue_redraw()


func _check_hit() -> void:
	var arm_angle: float = snapshot_angle
	var half: float = deg_to_rad(target_size * 0.5)
	var crit_half: float = deg_to_rad(critical_size * 0.5)
	var in_target: bool = arm_angle >= target_center - half and arm_angle <= target_center + half
	var in_crit: bool = arm_angle >= target_center - crit_half and arm_angle <= target_center + crit_half

	if in_crit:
		feedback_color = Color(0.2, 1.0, 0.3, 0.7)
		feedback_duration = 0.8
		SoundManager.play_crit_hit()
		if is_monster_alive():
			current_monster.show_crit_label()
			current_monster.take_damage(randi_range(2, 6))
	elif in_target:
		feedback_color = Color(0.2, 1.0, 0.3, 0.6)
		feedback_duration = 0.4
		SoundManager.play_hit()
		if is_monster_alive():
			current_monster.take_damage(randi_range(1, 3))
	else:
		feedback_color = Color(1.0, 0.2, 0.2, 0.6)
		feedback_duration = 0.4
		SoundManager.play_miss()
		if is_monster_alive() and monster_can_attack:
			current_monster.attack_player()

	feedback_timer = feedback_duration
	_skill_check_area.queue_redraw()


# ---------------------------------------------------------------------------
# Monster management
# ---------------------------------------------------------------------------

func spawn_new_monster() -> void:
	if current_monster and is_instance_valid(current_monster):
		current_monster.queue_free()
	current_monster = _monster_scene.instantiate()
	_monster_container.add_child(current_monster)
	current_monster.position = Vector2.ZERO
	current_monster.modulate = Color.WHITE
	SoundManager.play_zombie_spawn()
	monster_can_attack = false
	await get_tree().create_timer(1.0).timeout
	monster_can_attack = true


func is_monster_alive() -> bool:
	return current_monster != null and is_instance_valid(current_monster)


# ---------------------------------------------------------------------------
# Player damage
# ---------------------------------------------------------------------------

func take_damage_from_monster(amount: int) -> void:
	player_hp = max(player_hp - amount, 0)
	_update_hearts()
	SoundManager.play_monster_attack()
	SoundManager.play_player_hurt()
	if player_hp <= 0:
		_game_over()


func _game_over() -> void:
	state = State.IDLE
	monster_can_attack = false
	_hearts_label.text = "GAME OVER"
	_hearts_label.modulate = Color(1, 0.2, 0.2, 1)
	SoundManager.play_game_over()
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _update_hearts() -> void:
	var hearts: String = ""
	for i in range(max_player_hp):
		hearts += "❤️ " if i < player_hp else "🖤 "
	_hearts_label.text = hearts.strip_edges()


# ---------------------------------------------------------------------------
# Arm movement
# ---------------------------------------------------------------------------

func _update_arm(delta: float) -> void:
	if state == State.SWINGING:
		_speed_multiplier = move_toward(_speed_multiplier, 1.0, smoothness)
	elif state == State.CHECKING:
		_speed_multiplier = move_toward(_speed_multiplier, 0.0, smoothness)
	else:
		return
	_time += delta * _speed_multiplier
	_arm_pivot.rotation = sin(_time * swing_speed * TAU) * deg_to_rad(swing_range)


# ---------------------------------------------------------------------------
# Feedback
# ---------------------------------------------------------------------------

func _update_feedback(delta: float) -> void:
	if feedback_timer <= 0:
		if feedback_color.a > 0:
			feedback_color = Color.TRANSPARENT
			_skill_check_area.queue_redraw()
		return
	feedback_timer -= delta
	var alpha: float = clamp(feedback_timer / feedback_duration, 0.0, 1.0)
	feedback_color = Color(feedback_color.r, feedback_color.g, feedback_color.b, alpha * 0.6)
	_skill_check_area.queue_redraw()
