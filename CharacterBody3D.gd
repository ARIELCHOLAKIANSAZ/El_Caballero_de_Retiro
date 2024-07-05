extends CharacterBody3D

@onready var camera1 = $Camera
@onready var character = $"."
@onready var weapon = $Camera/PivotPivot/WeaponPivot/Weapon
@onready var pivot = $Camera/PivotPivot/WeaponPivot
@onready var ppivot = $Camera/PivotPivot
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
			weapon.rotation_degrees = Vector3(-90,0,0) 
			pivot.rotate_x(-event.relative.y * rotation_speed)
			ppivot.rotate_y(-event.relative.x * rotation_speed)
			print(event.relative.y)
		else:
			camera1.rotate_x(-event.relative.y * rotation_speed)
			character.rotate_y(-event.relative.x * rotation_speed)
			camera1.rotation.x = clamp(camera1.rotation.x, deg_to_rad(-90), deg_to_rad(90))

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(delta):
	if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		is_using_weapon = true
	else:
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
