extends KinematicBody

var curHp : int = 10
var maxHp : int = 10
var ammo : int = 15
var score : int = 0
var moveSpeed : float = 5.0
var jumpForce : float = 5.0
var gravity : float = 12.0
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 0.5
var input = Vector2()

var vel : Vector3 = Vector3()
var mouseDelta : Vector2 = Vector2()

var forward = global_transform.basis.z
var right = global_transform.basis.x

onready var camera = get_node("Camera")
onready var muzzle = get_node("Camera/Handmade_Shotgun/Muzzle")
onready var bulletScene = preload("res://Scenes/Bullet.tscn")

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

func _process(delta):
	camera.rotation_degrees -= Vector3(rad2deg(mouseDelta.y), 0, 0) * lookSensitivity * delta
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	rotation_degrees -= Vector3(0,rad2deg(mouseDelta.x), 0) * lookSensitivity * delta
	mouseDelta = Vector2()
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
func _physics_process(delta):
	vel.x = 0
	vel.y = 0
	
	if Input.is_action_pressed("move_forward"):
		input.y -= 1
	if Input.is_action_pressed("move_backward"):
		input.y += 1
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1
	if Input.is_action_pressed("jump") and is_on_floor():
		vel.y = jumpForce
	
	input = input.normalized()
	
	vel.z = (forward * input.y + right * input.x).z * moveSpeed
	vel.x = (forward * input.y + right * input.x).x * moveSpeed
	vel.y -= gravity * delta
	vel = move_and_slide(vel, Vector3.UP)
	
	if Input.is_action_pressed("jump") and is_on_floor():
		vel.y = jumpForce

func shoot ():
	var bullet = bulletScene.instance()
	get_node("/root/Game").add_child(bullet)
	bullet.global_transform = muzzle.global_transform
	bullet.scale = Vector3.ONE
	ammo -= 1

func ready():
	 Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func take_damage (damage):
	curHp -= damage
	if curHp <= 0:
		die()

func die ():
	pass

func add_score (amount):
	score += amount

func add_health (amount):
	curHp = clamp(curHp + amount, 0, maxHp)

func add_ammo (amount):
	ammo += amount
