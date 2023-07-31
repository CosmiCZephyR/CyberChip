extends Node

class_name Magnetic_shock

var is_on_cooldown: bool = false
var magnetic_shock_cooldown: int = 3

func activate_magnetic_shock(master) -> void:
	if not is_on_cooldown:
		is_on_cooldown = true
		var player_pos = master.get_global_position()
		var enemy = get_node("/root/TestScene/Room2/Enemy")
		var enemy_pos = enemy.get_global_position()
		if player_pos.distance_to(enemy_pos) <= 150:
			enemy.call("apply_shock")
		await get_tree().create_timer(magnetic_shock_cooldown).timeout
		is_on_cooldown = false
