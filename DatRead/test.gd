#!/usr/bin/env -S godot -s
@tool
extends SceneTree

var fname = "C:/Program Files (x86)/Steam/steamapps/common/Guild Wars 2/Gw2.dat"

func _init():
	print("Hello!")
	var lr = DatLocalReader.new(fname)
	print(lr)
	
	var someFile = lr.read_file(47135)
	print(someFile)
	
	lr.close()
	
	# QUIT (free variables first, so memory doesn't leak)
	# Update: doesn't work :thinking:
	#someFile = null
	lr.free()
	#quit()
