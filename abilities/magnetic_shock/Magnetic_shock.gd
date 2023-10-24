extends Node

class_name Magnetic_shock

var is_on_cooldown: bool = false
var cooldown_time: int = 3

func activate_magnetic_shock(master) -> void:
	if not is_on_cooldown:
		is_on_cooldown = true
		var player_pos = _get_player_position(master)
		var enemy = _get_enemy()
		
		if _is_within_range(player_pos, enemy):
			_apply_shock_to_enemy(enemy)
		
		await get_tree().create_timer(cooldown_time).timeout
		is_on_cooldown = false

func _get_player_position(master) -> Vector2:
	return master.get_global_position()

func _get_enemy() -> Node:
	return get_node("/root/TestScene/Room2/Enemy")

func _is_within_range(player_pos: Vector2, enemy: Node) -> bool:
	var enemy_pos = enemy.get_global_position()
	return player_pos.distance_to(enemy_pos) <= 150

func _apply_shock_to_enemy(enemy: Node) -> void:
	enemy.call("apply_shock")
