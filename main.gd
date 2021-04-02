extends Node2D


var graph = { #will be automatically updated via code (generateGraph())... this current data is for example!
				0:{"neighbors":[1, 2],    "local":0, "global":INF, "parent":null},
				1:{"neighbors":[0, 4, 3], "local":INF, "global":INF, "parent":null}, 
				2:{"neighbors":[0],    "local":INF, "global":INF, "parent":null},
				3:{"neighbors":[1],       "local":INF, "global":INF, "parent":null},
				4:{"neighbors":[1],    "local":INF, "global":INF, "parent":null},
			}
var linkName = 2 #used to name link nodes according to their place in existance


func JStar(start, end):
	var bestpath = []
	var currentNode = start #init as start node; contains current node
	var nodesToTest = [start] #contains promising nodes discovered that need to be tested
	var graphEdit = $GraphEdit
	
	while len(nodesToTest) > 0:
		#set current node to node with lowest global score known ...
		#... starts as infinity because anything is better than nothing
		var lowestFound = INF
		for i in nodesToTest: # > terrible sorting algorithm
			if graph[i]["global"] < lowestFound:
				lowestFound = i
		currentNode = lowestFound #pick the most promising node with the least distance
		print("Currently searching node: %s " % currentNode)
		nodesToTest.erase(currentNode) #we wont need to test this node again
		
		
		if currentNode == end:
			print("--- FOUND A PATH ---")
			bestpath = retracePath(end, start)
		
		
		#for all neighbors of the current node
		for i in graph[currentNode]["neighbors"]:
			#check if the node in question would benefit from the current path
			if graph[currentNode]["local"] < graph[i]["local"]:
				#if so, update the information of the new node, and set the parent to yourself.
				print("Updating Node: %s" % i)
				
				var distToNode = graphEdit.get_node(str(i)).rect_global_position.distance_to(graphEdit.get_node(str(currentNode)).rect_global_position)
				
				#update graph values:
				graph[i]["local"] = graph[currentNode]["local"] + distToNode #distance along the graph
				graph[i]["global"] = graphEdit.get_node(str(i)).rect_global_position.distance_to(graphEdit.get_node(str(end)).rect_global_position) #heuristic; helps with direction
				graph[i]["parent"] = currentNode
				
				nodesToTest.append(i) # we want to test this node in the future
				print(nodesToTest)
	for i in bestpath:
		$GraphEdit.get_node(str(i)).set_overlay(2)


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


# Convert values from the editable graph to a readable format for the algorithm
func generateGraph():
	var tempGraph = {}
	var graphEdit = $GraphEdit
	var connectionList = graphEdit.get_connection_list() #godot builtin func 
	var start #start node 
	var end #goal
	#link is an object reference
	for link in graphEdit.get_children():
		#check if link is actually a link!
		if link is GraphNode:
			#add link to the graph; use default values
			tempGraph[int(link.name)] = {"neighbors":[], "local":INF, "global":INF, "parent":null}
			
			#check if link is start/end node
			if link.start == true:
				start = int(link.name)
			elif link.end == true:
				end = int(link.name)
			
			#iterate through connection list and see if any are applicable for node at hand.
			for connection in connectionList:
				if int(connection["from"]) == int(link.name):
					#to optomize: delete connection once it's taken.
					tempGraph[int(link.name)]["neighbors"].append(int(connection["to"]))
	#setup the start node to contain a global value
	tempGraph[start]["global"] = graphEdit.get_node(str(start)).rect_global_position.distance_to(graphEdit.get_node(str(end)).rect_global_position)
	tempGraph[start]["local"] = 0
	
	#officially update the legitimate graph!
	graph = tempGraph
	
	#Now we can run the algorithm!
	JStar(start, end)

#run the algorithm, starting with generating the non-tangible graph! (the dict)
func _on_Button_pressed():
	generateGraph()

#instantiate a new link
func _on_Button2_pressed():
	var link = load("res://graphLink.tscn")
	var linkInstanced = link.instance()
	$GraphEdit.add_child(linkInstanced)
	linkInstanced.rect_position = get_global_mouse_position()
	
	linkInstanced.name = str(linkName)
	linkInstanced.title = linkInstanced.name
	linkName += 1

#create a new connection (edge) between links
func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	$GraphEdit.connect_node(from, from_slot, to, to_slot) #awesome builtin func!


func _on_Button3_pressed():
	get_tree().change_scene("res://main.tscn")
