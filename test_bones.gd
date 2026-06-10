tool
extends Node

func _ready():
	var skel = get_node("Player/Protagonist") as Skeleton3D
	if skel:
		for i in range(skel.get_bone_count()):
			var name = skel.get_bone_name(i)
			print("%d: %s" % [i, name])
	get_tree().quit()
