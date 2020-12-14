extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var game = get_parent().get_parent()
var line = preload("res://UI/ChatLine.tscn")
var windowOpen = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
func _input(event):
	if windowOpen == false:
		return
	if event.is_action_pressed("ui_accept"):
		_on_Button_pressed()
	if event.is_action_pressed("ui_cancel"):
		_on_ChatOpen_pressed()
func doChat(message):
	var newline = line.instance()
	newline.setup(message.user+": "+message.message)
	$ChatWindow/ScrollContainer/HBoxContainer.add_child(newline)
	if windowOpen == false:
		$ChatOpen/Sprite.modulate.a = 1
		#$AnimationPlayer.play("newMail")

func _on_Button_pressed():
	if $ChatWindow/LineEdit.text != "":
		game.sendChat($ChatWindow/LineEdit.text)
		$ChatWindow/LineEdit.text = ""
		$ChatWindow/LineEdit.grab_focus()

func _on_ChatOpen_pressed():
	if windowOpen == false:
		$ChatOpen/Sprite.modulate.a = 0
		$AnimationPlayer.play("ChatWindow")
		windowOpen = true
		$ChatWindow/LineEdit.grab_focus()
	else:
		$AnimationPlayer.play_backwards("ChatWindow")
		windowOpen = false
	pass # Replace with function body.
