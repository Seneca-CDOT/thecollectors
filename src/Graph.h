// This file describes the function prototypes for the Graph JavaScript class
function Graph(){
	nodeDictionary
	length
}
addNode(node){}										//takes a node object and adds it to the nodeDictionary
clearGraph(){}										//clears the nodeDictionary, resets the length
addConnection(nodeID, nodeToConnect, weight){}		//adds a connection with the specified weight to the two nodes, identified by their ID
findNodeArray(nodeID){}								//returns the Node object with the specified ID
areNodesConnected(nodeID, nodeIDMatch){}			//checks if two nodes are connected
vertexExists(vert){}								//checks if the specified vertex already exists within the nodes
													//returns the index of the node if it does exist
Length() 											//returns length of the nodeDictionary since it does not have a .length property