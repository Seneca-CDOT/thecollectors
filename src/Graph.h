// This file describes the function prototypes for the Graph JavaScript class
function Graph(){
	nodeDictionary
	length
}
addNode(node){}										//takes a node object and adds it to the nodeDictionary
clearGraph(){}										//clears the nodeDictionary, resets the length
addConnection(nodeID, nodeToConnect, weight){}		//adds a connection with the specified weight to the two nodes, identified by their ID
removeConnection(node1,node2){}						//removes the connection between 2 nodes, given their ID
findNodeArray(nodeID){}								//returns the Node object with the specified ID
areNodesConnected(nodeID, nodeIDMatch){}			//checks if two nodes are connected
vertexExists(vert){}								//checks if the specified vertex already exists within the nodes
													//returns the index of the node if it does exist
edgeIntersects(x1,y1,x2,y2){}						//checks if the specifed line intersects with any lines in the graph
getEdgeList(){}										//returns an object containing all edges
removeNode(nodeId){}								//removes a node from the graph
Length(){} 											//returns length of the nodeDictionary since it does not have a .length property
numConnections(){}									//returns the number of connections in the Graph
randomNode(){}										//returns a random node