@tool
extends EditorScript

const test = preload("test.gd")

func _run() -> void:
	var t = test.new()
	t.free()
