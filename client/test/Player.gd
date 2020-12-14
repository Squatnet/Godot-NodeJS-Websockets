extends KinematicBody2D

onready var map = get_parent().get_node("TileMap")

var speed = 200  # speed in pixels/sec

var velocity = Vector2.ZERO

func get_input():
	velocity = Vector2.ZERO
	if Input.is_action_pressed('move_right'):
		velocity.x += 1
	if Input.is_action_pressed('move_left'):
		velocity.x -= 1
	if Input.is_action_pressed('move_down'):
		velocity.y += 1
	if Input.is_action_pressed('move_up'):
		velocity.y -= 1
	# Make sure diagonal movement isn't faster
	velocity = velocity.normalized() * speed

func _input(event):
	if event.is_action_pressed("ui_accept"):
		var i = global_position
		var playerTileMapPosition = map.to_local(i)
		var playerCellCoordinates = map.world_to_map(playerTileMapPosition)
		var playerTileId = map.get_cellv(playerCellCoordinates)
		print(global_position)
		print(playerTileMapPosition)
		print(playerCellCoordinates)
		print(playerTileId)
func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)
	
