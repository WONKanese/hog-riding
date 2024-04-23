extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -600.0
@export var GRAVITY_POWER = 1.5

#Double jumping
@export var DOUBLE_JUMP_POWER = -500.0
var jumps_left = 1 #doesnt matter what var is set

var air := false
var start_pos
var max_jumps = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var totalJumps = 0

@onready var landSFX = $LandSound
@onready var jumpSFX = $JumpSound
@onready var jumpTXT = get_node("/root/Node2D/Control/Jumps")
@onready var anim_tree := $AnimationTree

func _process(delta):
	update_animation_parameters()
func _ready():
	start_pos = global_position
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		air = true
		velocity.y += gravity * GRAVITY_POWER * delta
	else:
		if air:
			landSFX.play()
		air = false
		#reset double jumps
		jumps_left = max_jumps
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			totalJumps += 1
			jumpSFX.play()
		elif jumps_left != 0:
			totalJumps += 1
			jumps_left -= 1
			velocity.y = DOUBLE_JUMP_POWER
			jumpSFX.play()
		
		jumpTXT.text = "Hog Rider's Jumps: " + str(totalJumps)
			
			

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction == 1:
		$Sprite2D.scale.x = 1.024
	elif direction == -1:
		$Sprite2D.scale.x = -1.024
	
	move_and_slide()

func positive(dir):
	if dir > 0:
		return true
	else:
		return false

func update_animation_parameters():
	if velocity == Vector2.ZERO:		
		anim_tree["parameters/conditions/is_idle"] = true
		anim_tree["parameters/conditions/is_moving"] = false
	else:
		anim_tree["parameters/conditions/is_moving"] = true
		anim_tree["parameters/conditions/is_idle"] = false


func _on_area_2d_body_entered(body):
	
	if body.get_parent().name == "Spikes":
		global_position = start_pos
		$die.play() 
	if body.get_parent().name == "Launchpads":
		velocity.y = JUMP_VELOCITY * 1.5
		$Spring.play()
	if body.name == "End":
		get_tree().change_scene_to_file("res://end.tscn")
	elif body.get_parent().name == "Checkpoints":
		body.get_node("win").emitting = true
		body.get_node("winsound").play()
		start_pos = global_position
