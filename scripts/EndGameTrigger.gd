extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	#TODO: normal credits and end game cutscene, but it'll be done much later
	if body is Player:
		get_tree().quit()
