extends Area2D

@onready var level: Level = get_parent()
@onready var saver = Saver.new()

func _ready() -> void:
	InputHandler.save.connect(_on_save_pressed)

func _process(delta: float) -> void:
	pass

func _on_save_pressed():
	for body in get_overlapping_bodies():
		print_debug(body.name)
		if body.is_in_group("Player"):
			level.update_values_before_save()
			saver.save_game_data(level.save_resource)
