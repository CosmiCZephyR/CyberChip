extends Node

class_name Magnetic_shock

var is_on_cooldown: bool = false
var magnetic_shock_cooldown: int = 3

@warning_ignore("shadowed_variable_base_class")
func activate_magnetic_shock(owner) -> void:
	if not is_on_cooldown:
		is_on_cooldown = true
		var player_pos = owner.get_global_position()
		var enemy = get_node("/root/TestScene/Room2/Enemy")
		var enemy_pos = enemy.get_global_position()
		if player_pos.distance_to(enemy_pos) <= 150:
			enemy.call("apply_shock")
		await get_tree().create_timer(magnetic_shock_cooldown).timeout
		is_on_cooldown = false
