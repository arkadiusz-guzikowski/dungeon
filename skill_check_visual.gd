extends Node2D

## Rysuje wizualizację skill checka — tarczę, strefę trafienia i strefę krytyczną.

@onready var _main: Node2D = $".."


func _draw() -> void:
	var center := Vector2.ZERO
	var r: float = _main.circle_radius

	_draw_rings(center, r)
	_draw_ticks(center, r)
	_draw_center_dot(center)

	if _main.target_active:
		_draw_target_zone(center, r)
		_draw_critical_zone(center, r)

	if _main.feedback_timer > 0:
		draw_circle(center, r, _main.feedback_color)
		draw_circle(center, r * 0.6, Color(
			_main.feedback_color.r,
			_main.feedback_color.g,
			_main.feedback_color.b,
			_main.feedback_color.a * 0.5
		))


func _draw_rings(center: Vector2, r: float) -> void:
	draw_circle(center, r, Color(0.2, 0.5, 0.9, 0.3), false, 3.0)
	draw_circle(center, r, Color(0.4, 0.7, 1.0, 0.6), false, 1.5)
	draw_circle(center, r - 6.0, Color(0.15, 0.4, 0.8, 0.15), false, 1.0)
	for i in range(5):
		var grad_r: float = r * (0.2 + i * 0.15)
		draw_circle(center, grad_r, Color(0.2, 0.5, 0.9, 0.03), false, 1.0)


func _draw_ticks(center: Vector2, r: float) -> void:
	for i in range(12):
		var angle_deg: float = -90.0 + (float(i) / 12.0) * 180.0
		var a: float = deg_to_rad(angle_deg)
		var dir := Vector2(sin(a), -cos(a))
		var tick_len: float = 6.0 if i % 3 == 0 else 3.0
		var tick_width: float = 2.0 if i % 3 == 0 else 1.0
		var tick_alpha: float = 0.5 if i % 3 == 0 else 0.25
		draw_line(dir * (r - 2.0), dir * (r - 2.0 - tick_len), Color(0.5, 0.8, 1.0, tick_alpha), tick_width)


func _draw_center_dot(center: Vector2) -> void:
	draw_circle(center, 4.0, Color(0.4, 0.7, 1.0, 0.8))
	draw_circle(center, 2.0, Color(0.8, 0.9, 1.0, 1.0))


func _draw_target_zone(center: Vector2, r: float) -> void:
	var half: float = deg_to_rad(_main.target_size * 0.5)
	var inner: float = r - 10.0
	var outer: float = r + 3.0
	var segments: int = 12

	var points := _arc_points(center, _main.target_center - half, _main.target_center + half, inner, outer, segments)
	draw_polygon(points, [Color(0.2, 1.0, 0.3, 0.7)])

	var inner_points := _arc_points(center, _main.target_center - half, _main.target_center + half, inner, inner + 2.0, segments)
	draw_polygon(inner_points, [Color(0.6, 1.0, 0.6, 0.9)])


func _draw_critical_zone(center: Vector2, r: float) -> void:
	var half: float = deg_to_rad(_main.critical_size * 0.5)
	var inner: float = r - 14.0
	var outer: float = r + 7.0
	var segments: int = 8

	var points := _arc_points(center, _main.target_center - half, _main.target_center + half, inner, outer, segments)
	draw_polygon(points, [Color(1.0, 0.15, 0.15, 0.7)])

	var outline := _arc_points(center, _main.target_center - half, _main.target_center + half, inner, outer, segments)
	draw_polyline(outline, Color(1.0, 0.5, 0.5, 0.9), 1.5)


func _arc_points(center: Vector2, from_angle: float, to_angle: float, inner_r: float, outer_r: float, segments: int) -> PackedVector2Array:
	var points: PackedVector2Array = []
	for i in range(segments + 1):
		var a: float = from_angle + (float(i) / segments) * (to_angle - from_angle)
		points.append(center + Vector2(sin(a), -cos(a)) * outer_r)
	for i in range(segments, -1, -1):
		var a: float = from_angle + (float(i) / segments) * (to_angle - from_angle)
		points.append(center + Vector2(sin(a), -cos(a)) * inner_r)
	return points
