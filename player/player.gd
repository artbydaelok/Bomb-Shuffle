extends CharacterBody2D
class_name Player

const SPEED = 500
const JUMP_VELOCITY = -600.0
const ACCELERATION = 1500
const FRICTION = 25

var push_force = 500

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var push_area = $PushArea

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _physics_process(delta):
	if not $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = move_toward(velocity.x, SPEED * direction, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION)
		
	move_and_slide()
	
func _process(_delta):
	if not $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		return
	if Input.is_action_just_pressed("push"):
		for body in push_area.get_overlapping_bodies():
			if body.is_in_group("player") and not body == self:
				print(body)
				push_away.rpc(body)

@rpc("any_peer", "call_local")
func push_away(player: Player):
	var direction_to_push = global_position.direction_to(player.global_position)
	player.launch_player.rpc(direction_to_push * push_force)

@rpc("any_peer", "call_local")
func launch_player(new_velocity: Vector2):
	velocity = new_velocity
