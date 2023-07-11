extends Node

class_name Magnetic_shock

var is_on_cooldown: bool = false
var magnetic_shock_cooldown: int = 3

func activate_magnetic_shock(owner) -> void:
	if Input.is_action_pressed("MagneticShock") and not is_on_cooldown:
		is_on_cooldown = true
		var player_pos = owner.get_global_position()
		# TODO: переименовать класс enemy в паскалькейс (с больших букв)
		var enemy = get_node("/root/TestScene/Enemy")
		var enemy_pos = enemy.get_global_position()
		print(player_pos.distance_to(enemy_pos))
		if player_pos.distance_to(enemy_pos) <= 150:
			print("condition is true")
			enemy.call("apply_shock")
		await get_tree().create_timer(magnetic_shock_cooldown).timeout
		is_on_cooldown = false
