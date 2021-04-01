extends Node2D


var graph = { 
				0:{"neighbors":[1, 2],    "local":0, "global":INF, "parent":null},
				1:{"neighbors":[0, 4, 3], "local":INF, "global":INF, "parent":null}, 
				2:{"neighbors":[0],    "local":INF, "global":INF, "parent":null},
				3:{"neighbors":[1],       "local":INF, "global":INF, "parent":null},
				4:{"neighbors":[1],    "local":INF, "global":INF, "parent":null},
			}


func _ready():
	graph[0]["global"] = get_node("0").position.distance_to(get_node("4").position)
	JStar(0, 4)


func JStar(start, end):
	var currentNode = start #init as start node; contains current node
	var nodesToTest = [start] #contains promising nodes discovered that need to be tested
	
	while len(nodesToTest) > 0:
		#set current node to node with lowest global score known
		var lowestFound = INF
		for i in nodesToTest: # > terrible sorting algorithm
			if graph[i]["global"] < lowestFound:
				lowestFound = i
		currentNode = lowestFound
		print("Currently searching node: %s " % currentNode)
		nodesToTest.erase(currentNode)
		
		if currentNode == end:
			print("--- FOUND A PATH ---")
			print(retracePath(end, start))
		
		nodesToTest.erase(currentNode)
		
		#for all neighbors of the current node
		for i in graph[currentNode]["neighbors"]: 
			#check if the node in question would benefit from the current path
			if graph[currentNode]["local"] < graph[i]["local"]:
				#if so, update the information of the new node, and set the parent to yourself.
				print("Updating Node: %s" % i)
				var distToNode = get_node(str(i)).position.distance_to(get_node(str(currentNode)).position)
				graph[i]["local"] = graph[currentNode]["local"] + distToNode #distance along the graph
				graph[i]["global"] = get_node(str(i)).position.distance_to(get_node(str(end)).position) #heuristic; helps with direction
				graph[i]["parent"] = currentNode
				nodesToTest.append(i)


func retracePath(end, start):
	#Retrace the path once we've found the end, and all applicable nodes are checked
	#Essentially just look to follow a route of "parents". The AStar function has already set these up for us.
	#Parents were changed on the basis of the fastest path!
	var currentNode = end
	var path = []
	while currentNode != start:
		path.append(currentNode)
		currentNode = graph[currentNode]["parent"]
	path.append(start) #add start node to path, because the while loop excludes it.
	return path
