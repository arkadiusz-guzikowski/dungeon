
extends Control

## Ekran glowny - tytul, Start Game, Options.

@onready var _start_label: Label = $VBoxContainer/StartLabel
@onready var _options_label: Label = $VBoxContainer/OptionsLabel
@onready var _selection: ColorRect = $Selection
@onready var _options_panel: Control = $OptionsPanel
@onready var _music_slider: HSlider = $OptionsPanel/Panel/MusicSlider
@onready var _music_value: Label = $OptionsPanel/Panel/MusicValue
@onready var _sfx_slider: HSlider = $OptionsPanel/Panel/SfxSlider
@onready var _sfx_value: Label = $OptionsPanel/Panel/SfxValue
@onready var _back_label: Label = $OptionsPanel/Panel/BackLabel
@onready var _options_selection: ColorRect = $OptionsPanel/Panel/OptionsSelection

var _selected: int = 0
var _in_options: bool = false
var _options_selected: int = 0
var _options_count: int = 3  # Music slider, SFX slider, Back


func _ready() -> void:
	_update_selection()
	SoundManager.play_menu_music()
	_music_slider.value = SoundManager.get_menu_music_volume()
	_sfx_slider.value = SoundManager.get_sfx_volume()
	_update_music_value()
	_update_sfx_value()
	_music_slider.value_changed.connect(_on_music_slider_changed)
	_sfx_slider.value_changed.connect(_on_sfx_slider_changed)


func _process(_delta: float) -> void:
	if _in_options:
		_handle_options_input()
	else:
		_handle_main_input()


func _handle_main_input() -> void:
	if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"):
		_selected = 1 - _selected
		_update_selection()

	if Input.is_action_just_pressed("ui_accept"):
		match _selected:
			0:
				_start_game()
			1:
				_open_options()


func _handle_options_input() -> void:
	if Input.is_action_just_pressed("ui_down"):
		_options_selected = (_options_selected + 1) % _options_count
		_update_options_selection()

	if Input.is_action_just_pressed("ui_up"):
		_options_selected = (_options_selected - 1 + _options_count) % _options_count
		_update_options_selection()

	if Input.is_action_just_pressed("ui_accept"):
		match _options_selected:
			2:  # Back
				_close_options()

	if Input.is_action_just_pressed("ui_cancel"):
		_close_options()

	# Obsługa suwaków strzałkami lewo/prawo
	if Input.is_action_just_pressed("ui_left"):
		match _options_selected:
			0:  # Music
				_music_slider.value -= _music_slider.step
			1:  # SFX
				_sfx_slider.value -= _sfx_slider.step

	if Input.is_action_just_pressed("ui_right"):
		match _options_selected:
			0:  # Music
				_music_slider.value += _music_slider.step
			1:  # SFX
				_sfx_slider.value += _sfx_slider.step


func _on_music_slider_changed(value: float) -> void:
	SoundManager.set_menu_music_volume(value)
	_update_music_value()


func _on_sfx_slider_changed(value: float) -> void:
	SoundManager.set_sfx_volume(value)
	_update_sfx_value()


func _update_music_value() -> void:
	_music_value.text = str(int(_music_slider.value))


func _update_sfx_value() -> void:
	_sfx_value.text = str(int(_sfx_slider.value))


func _open_options() -> void:
	_in_options = true
	_options_selected = 0
	_options_panel.visible = true
	_music_slider.value = SoundManager.get_menu_music_volume()
	_sfx_slider.value = SoundManager.get_sfx_volume()
	_update_music_value()
	_update_sfx_value()
	_update_options_selection()


func _close_options() -> void:
	_in_options = false
	_options_panel.visible = false


func _start_game() -> void:
	get_tree().change_scene_to_file("res://agent.tscn")


func _update_selection() -> void:
	var labels := [_start_label, _options_label]
	var label: Label = labels[_selected]
	_selection.position = Vector2(label.global_position.x - 20, label.global_position.y)
	_selection.size = Vector2(label.size.x + 40, label.size.y)


func _update_options_selection() -> void:
	match _options_selected:
		0:  # Music slider
			_options_selection.position = Vector2(20, 65)
			_options_selection.size = Vector2(460, 35)
		1:  # SFX slider
			_options_selection.position = Vector2(20, 115)
			_options_selection.size = Vector2(460, 35)
		2:  # Back
			_options_selection.position = Vector2(20, 170)
			_options_selection.size = Vector2(460, 40)
