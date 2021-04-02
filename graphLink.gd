extends GraphNode



export var start = false
export var end = false


func _ready():
	var x = 0
	
	if start == false:
			print("no")
			var main = get_parent().get_parent()
			var priornode = get_node("../"+str(main.linkName - 1))
			print(priornode)
			offset += priornode.offset + Vector2(-20, -20)
			if end == false:
				title = name
	for i in get_children():
		set_slot(x, true, 0, Color(0,1,0,1), true, 0, Color(1,.5,0,1) )
		x += 1
	


