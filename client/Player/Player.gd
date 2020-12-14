extends KinematicBody2D
#warnings-disable
var speed = 400
var screen_size
var loc
var fr = 0
var velo = Vector2.ZERO
onready var game = get_parent().get_parent()
func _ready():
	screen_size = get_viewport_rect().size
	
func setMod(col):
	modulate = Color(col.r,col.g,col.b)
func get_input():
	velo = Vector2.ZERO
	if game.chat.windowOpen == true:
		pass
	else:
		if Input.is_action_pressed("move_up"):
			velo.y -= 1
		if Input.is_action_pressed("move_down"):
			velo.y += 1
		if Input.is_action_pressed("move_left"):
			velo.x -= 1
		if Input.is_action_pressed("move_right"):
			velo.x += 1
	velo = velo.normalized() * speed
func _physics_process(delta):
	fr += 1
	get_input()
	velo = move_and_slide(velo)
	## send to server here
	rotation = (velo.angle())
	if fr > 10:
		get_parent().get_parent().sendPos({"x":position.x,"y":position.y})
		fr = 0
