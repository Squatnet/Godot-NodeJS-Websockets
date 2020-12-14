extends KinematicBody2D

var speed = 400
var target = null
var velocity = Vector2.ZERO


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#modulate = Color(randf(),randf(),randf())

func setPos(dd):
	if !dd.has("x"):
		return
	var pos = Vector2(dd.x,dd.y)
	#print(get_name()+" called setpos")
	target = pos
func setCol(col):
	if col.has("r"):
		modulate = Color(col.r,col.g,col.b)
func setUser(user):
	$Label.text = user
func die():
	print("KILLING "+get_name())
	queue_free()

func _physics_process(delta):
	if target:
		look_at(target)
		$Label.set_rotation(-rotation)
		velocity = transform.x * speed
		# stop moving if we get close to the target
		if position.distance_to(target) > 5:
			velocity = move_and_slide(velocity)
		else:
			target = null
