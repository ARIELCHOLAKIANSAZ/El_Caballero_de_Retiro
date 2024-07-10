extends Node3D


@onready var camera = $Body/POV
@onready var character = $Body
@onready var weapon = $yPivot/xPivot/Weapon
@onready var xpivot = $yPivot/xPivot
@onready var ypivot = $yPivot
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
			xpivot.rotation.x = clamp(xpivot.rotation.x, deg_to_rad(-30),deg_to_rad(30)) 
			ypivot.rotation.y = clamp(ypivot.rotation.y, deg_to_rad(get_min_max_y_from_dir(-50)),deg_to_rad(get_min_max_y_from_dir(+50))) 
		else:
			camera.rotate_x(-event.relative.y * rotation_speed)
			character.rotate_y(-event.relative.x * rotation_speed)
			
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func get_min_max_y_from_dir(min_mod):
	if(min_mod + character.rotation.y < -PI):
		return(PI+min_mod + character.rotation.y+PI)
	elif(min_mod + character.rotation.y > PI):
		return(-(PI-(min_mod+character.rotation.y-PI)))
	else:
		return(min_mod + character.rotation.y)
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta):
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		if(is_using_weapon == false):
			is_using_weapon = true
			xpivot.rotation_degrees = Vector3(0,0,0)
			ypivot.rotation_degrees = Vector3(0,0,0)
			#weapon.rotation_degrees = Vector3(-90,0,0)
			
	else:
		if(is_using_weapon == true):
			is_using_weapon = false
			xpivot.rotation_degrees = Vector3(0,0,0)
			ypivot.rotation_degrees = Vector3(0,-30,0)
			#weapon.rotation_degrees = Vector3(-15,0,0)
		is_using_weapon = false
		ypivot.rotation = character.rotation
		print(ypivot.rotation)
		print(character.rotation)
		xpivot.rotation = camera.rotation

func _physics_process(delta):
	# Add the gravity.
	if not character.is_on_floor():
		character.velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and character.is_on_floor():
		character.velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		character.velocity.x = character.direction.x * SPEED
		character.velocity.z = character.direction.z * SPEED
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, SPEED)
		character.velocity.z = move_toward(character.velocity.z, 0, SPEED)
	
	ypivot.position = character.position
	
	character.move_and_slide()
