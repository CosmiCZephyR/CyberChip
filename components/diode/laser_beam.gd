extends RayCast2D

var is_casting: bool = false: set = set_is_casting
var tween: Tween = Tween.new()

func _ready() -> void:
	set_physics_process(false)
	$Line2D.points[1] = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		self.is_casting = event.pressed

func _physics_process(delta: float) -> void:
	var cast_point := target_position
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
	
	$Line2D.points[1] = cast_point

func set_is_casting(cast: bool) -> void:
	is_casting = cast
	
	if is_casting:
		appear()
	else:
		disappear()
	
	set_physics_process(is_casting)

func appear() -> void:
	print_debug("appear")
	tween.stop()
	$Line2D.width = tween.interpolate_value(0, 10, 10, 1000, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.play()

func disappear() -> void:
	print_debug("disappear")
	tween.stop()
	$Line2D.width = tween.interpolate_value(10, 0, 10, 1000, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.play()
