extends ShapeCast3D
var blood = preload("res://BloodEmittor.tscn")
var collided : bool
@onready var pointer = $Pointer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding():
		if collided == false:
			var cpoint = get_collision_point(0) - global_position
			var rot = transform.looking_at(cpoint)
			var inst = blood.instantiate()
			inst.transform.rotation = rot
			inst.position = cpoint
			print(pointer.rotation_degrees)
			add_child(inst)
			collided = true
	else:
		collided = false

