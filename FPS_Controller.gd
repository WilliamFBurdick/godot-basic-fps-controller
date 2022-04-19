extends KinematicBody

export var walk_speed = 20
export var walk_acceleration = 5
export var jump_speed = 9
export var gravity_strength = 20
export var mouse_sensitivity = 0.05
export var max_slope_angle = 45
export var max_look_angles = Vector2(-90, 90)

#Onready vars
onready var camera_arm = $CameraArm

#Input variables
var input_vector : Vector2
var input_jump : bool

#Functional variables
var direction : Vector3
var movement_vector : Vector3
var horizontal_velocity : Vector3

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	mouse_toggle()
	process_input()

func _physics_process(delta):
	process_horizontal_movement(delta)
	process_vertical_movement(delta)
	
	move(delta)

#helper function used to exposing mouse when debugging
func mouse_toggle():
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#Grab player input and store it in helper variables
func process_input():
	input_vector = Vector2()
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	input_jump = Input.is_action_pressed("jump") 

#Calculate and adjust the movement vector for the player's horizontal movement
func process_horizontal_movement(delta):
	var direction = ((self.global_transform.basis.x * input_vector.x) + (self.global_transform.basis.z * input_vector.y)).normalized()
	
	var speed = walk_speed
	var accel = walk_acceleration
	
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction * speed, accel * delta)
	movement_vector = Vector3(horizontal_velocity.x, movement_vector.y, horizontal_velocity.z)

#Adjust the movement vector's Y component for vertical movement
func process_vertical_movement(delta):
	movement_vector.y -= gravity_strength * delta
	if input_jump and is_on_floor():
		movement_vector.y = jump_speed

func move(delta):
	movement_vector = move_and_slide(movement_vector, Vector3.UP, 0.05, 4, deg2rad(max_slope_angle))

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		self.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		camera_arm.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		camera_arm.rotation.x = clamp(camera_arm.rotation.x, deg2rad(max_look_angles.x), deg2rad(max_look_angles.y))
