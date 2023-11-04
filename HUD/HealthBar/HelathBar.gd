class_name HealthBar
extends HBoxContainer

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var last_segment: Node

@onready var segments: Array[Node] = get_children(true)
@onready var active_segments: Array[Node] = segments
@onready var unactive_segments: Array[Node]

@onready var segments_count: int = get_child_count()

func _ready():
	if len(segments) > segments_count:
		segments.resize(segments_count)
		active_segments = segments
	
	player.damage_applied.connect(_on_damage_applied)
	player.health_healed.connect(_on_health_healed)

func _on_damage_applied():
	last_segment = active_segments.back()
	last_segment.element_texture.visible = false
	
	unactive_segments.append(last_segment)
	
	active_segments.pop_back()

func _on_health_healed():
	if not unactive_segments.is_empty():
		last_segment = active_segments.back()
		last_segment.element_texture.visible = true
		
		var last_segment_index = unactive_segments.front()
		
		active_segments.append(last_segment_index)
