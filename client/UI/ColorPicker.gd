extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getColour():
	return $ColorRect.color

func _on_RSlider_value_changed(value):
	$ColorRect.color.r = value

func _on_GSlider_value_changed(value):
	$ColorRect.color.g = value

func _on_BSlider_value_changed(value):
	$ColorRect.color.b = value
