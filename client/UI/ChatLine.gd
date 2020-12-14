extends Control

func _ready():
	rect_min_size.y = $Label.rect_size.y
func setup(line):
	$Label.text = line
