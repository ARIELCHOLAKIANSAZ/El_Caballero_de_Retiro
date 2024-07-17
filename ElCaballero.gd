extends CharacterBody3D
@onready var camera = $POV
@onready var weapon = $POV/yPivot/xPivot/yWeaPivot/xWeaPivot/zWeaPivot/Weapon
@onready var xpivot = $POV/yPivot/xPivot
@onready var ypivot = $POV/yPivot
@onready var xweapiv = $POV/yPivot/xPivot/yWeaPivot/xWeaPivot
@onready var yweapiv = $POV/yPivot/xPivot/yWeaPivot
@onready var zweapiv = $POV/yPivot/xPivot/yWeaPivot/xWeaPivot/zWeaPivot
@onready var pointer = $POV/yPivot/xPivot/yWeaPivot/xWeaPivot/ball
var wcol : bool
var avgx : Array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
var avgy : Array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
var travgx : float = 0
var travgy : float = 0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var rotation_speed : float = 0.005
var is_using_weapon : bool = false
func _unhandled_input(event):
	if Input.is_key_pressed(KEY_SPACE):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_key_pressed(KEY_ESCAPE):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if(is_using_weapon):
			xpivot.rotate_x(-event.relative.y * rotation_speed)
			ypivot.rotate_y(-event.relative.x * rotation_speed)
			xweapiv.rotate_x(-event.relative.y * rotation_speed)
			yweapiv.rotate_y(-event.relative.x * rotation_speed)
			xpivot.rotation.x = clamp(xpivot.rotation.x, deg_to_rad(-30),deg_to_rad(90)) 
			ypivot.rotation.y = clamp(ypivot.rotation.y, deg_to_rad(-50),deg_to_rad(50)) 
			xweapiv.rotation.x = clamp(xweapiv.rotation.x, deg_to_rad(-10),deg_to_rad(90)) 
			yweapiv.rotation.y = clamp(yweapiv.rotation.y, deg_to_rad(-50),deg_to_rad(50)) 
			if(wcol):
				camera.rotate_x(-event.relative.y * rotation_speed)
				rotate_y(-event.relative.x * rotation_speed)
				camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			if(event.relative.x != 0):
				avgx.pop_at(0)
				avgx.append(event.relative.x)
			if(event.relative.y != 0):
				avgy.pop_at(0)
				avgy.append(event.relative.y)
			for i in avgx:
				travgx += i
			travgx /= 200
			for i in avgy:
				travgy += i
			travgy /= -200
			pointer.position = Vector3(travgx,travgy,0)
			zweapiv.look_at(pointer.global_position)
			zweapiv.rotation.x = 0 
			zweapiv.rotation.y = 0 
			zweapiv.rotation_degrees.z += 90
		else:
			rotate_y(-event.relative.x * rotation_speed)
			camera.rotate_x(-event.relative.y * rotation_speed)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(_delta):
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		if(is_using_weapon == false):
			is_using_weapon = true
			ypivot.rotation_degrees = Vector3(0,0,0)
			weapon.rotation_degrees = Vector3(-90,0,0)
	else:
		if(is_using_weapon == true):
			is_using_weapon = false
			xpivot.rotation_degrees = Vector3(0,0,0)
			ypivot.rotation_degrees = Vector3(0,-30,0)
			xweapiv.rotation_degrees = Vector3(0,0,0)
			yweapiv.rotation_degrees = Vector3(0,0,0)
			zweapiv.rotation_degrees = Vector3(0,0,0) 
			weapon.rotation_degrees = Vector3(-15,0,0)
		is_using_weapon = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _on_weapon_collision_body_entered(_body):
	wcol = true
func _on_weapon_collision_body_exited(_body):
	wcol = false
