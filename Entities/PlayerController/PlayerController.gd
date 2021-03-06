extends KinematicBody

const rotationSpeed = 2.0 / 1000
const maxSpeedOnGround = 3.5
const maxSpeedinAir = 4
const movementSharpnessGround = 10
const jumpForce = 6.5
const gravity = 18

# Player Controller Children
onready var camera = $FPSCamera

# GUI
onready var gui = $PlayerGUI
onready var gui_mouseLock = $PlayerGUI/MouseLockWarning

# Camera Variables
var lock_mouse = true
var yaw_delta = 0
var pitch_delta = 0
var pitch = 0

# Movement Variables
var targetVelocity : Vector3 = Vector3()
var charVelocity : Vector3 = Vector3()
var onFloorLastFrame : bool = false

var busy : bool = false
var pause : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	# Rotate camera horizontally and vertically
	self.rotate_y(yaw_delta * rotationSpeed)
	camera.rotate_x(pitch_delta * rotationSpeed)
	yaw_delta = 0
	pitch_delta = 0
	var pitch = camera.transform.basis.get_euler().x

func _physics_process(delta):
	if pause:
		return
	#checkIfGrounded()
	
	if (is_on_floor()):
		onFloorLastFrame = true
		targetVelocity = getMoveDirection() * maxSpeedOnGround
		targetVelocity += Vector3(0, -5, 0)
		charVelocity = charVelocity.linear_interpolate(targetVelocity, movementSharpnessGround * delta)
		
		if (Input.is_action_pressed("jump")):
			charVelocity = Vector3(charVelocity.x, 0, charVelocity.z)
			charVelocity += Vector3.UP * jumpForce
			onFloorLastFrame = false
	else:
		# Cancel out high gravity used to snap player to ground
		if onFloorLastFrame == true or is_on_ceiling():
			charVelocity = Vector3(charVelocity.x, 0, charVelocity.z)
		onFloorLastFrame = false
		
		# Air Strafing
		charVelocity += getMoveDirection() * 15 * delta
		
		var horizontalVelocity = Plane(Vector3.UP, 0).project(charVelocity)
		horizontalVelocity *= 0.95
		if (horizontalVelocity.length() > maxSpeedinAir):
			horizontalVelocity = horizontalVelocity.normalized() * maxSpeedinAir
			
		charVelocity = Vector3(horizontalVelocity.x, charVelocity.y, horizontalVelocity.z)
		charVelocity += Vector3.DOWN * gravity * delta
	
	move_and_slide(charVelocity, Vector3(0, 1, 0))

func checkIfGrounded():
	var space = get_world().direct_space_state as PhysicsDirectSpaceState
	var params = PhysicsShapeQueryParameters.new()
	params.exclude = [self]
	params.set_shape($CollisionShape.shape)
	params.set_transform($CollisionShape.global_transform)

	var motionTest = space.cast_motion(params, Vector3(0, -1, 0))
	print (motionTest)
	
	# Get collision info
	params.transform.origin += Vector3(0, -1, 0) * motionTest[1]
	var restInfo = space.get_rest_info(params)
	if (not restInfo.empty()):
		var angle = Vector3(0, 1, 0).dot(restInfo["normal"])
		print("Normal: " + str(angle))
	
	if (motionTest[0] < 0.1):
		self.transform.origin += Vector3(0, -1, 0) * motionTest[0]
	
#	if (test_move(transform, Vector3(0, -0.2, 0))):
#		print("on the ground")
#	else:
#		print("off")
#		charVelocity = charVelocity + Vector3(0, -1, 0)

func _unhandled_input(event):
	if event is InputEventMouseMotion and lock_mouse:
		var new_pitch = pitch + (-event.relative.y * rotationSpeed)
		if (new_pitch < (PI/2 - 0.1)) and (new_pitch > (-PI/2 + 0.1)):
			pitch_delta -= event.relative.y
			pitch = new_pitch
		yaw_delta -= event.relative.x
	
	if event is InputEventKey and event.pressed:
		if event.is_action("toggle_mouse_lock"):
			lock_mouse = not lock_mouse
			match lock_mouse:
				true: 
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					gui_mouseLock.visible = false
				false: 
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					gui_mouseLock.visible = true

func getMoveDirection() -> Vector3:
	var dirVector = Vector3()
	if Input.is_action_pressed("move_forward"):
		dirVector += (-camera.global_transform.basis.z * Vector3(1,0,1)).normalized()
	if Input.is_action_pressed("move_back"):
		dirVector += (camera.global_transform.basis.z * Vector3(1,0,1)).normalized()
	if Input.is_action_pressed("move_left"):
		dirVector += (-camera.global_transform.basis.x * Vector3(1,0,1)).normalized()
	if Input.is_action_pressed("move_right"):
		dirVector += (camera.global_transform.basis.x * Vector3(1,0,1)).normalized()
	
	return dirVector
