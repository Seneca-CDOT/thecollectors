// This file describes the function prototypes for the Node JavaScript class
function Node(uID,x,y){
	id
	vertex
	connections 					//associative array of connected nodes and connection weights
	connectionsLength				//number of connections
}
position(){}						//returns the vertex of the node
equals(node){}						//checks if the ids of the nodes are equal
push(nodeId) {}						//push a node into the connections list
existingConnection(nodeId){}		//checks if the connection exists already
removeConnection(nodeId){}			//removes connection to a node