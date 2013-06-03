// This file describes the function prototypes for the Graph JavaScript class
function Graph()
Graph.prototype.addNode = function(node, connectionIdList)
Graph.prototype.clearGraph = function()
Graph.prototype.addConnection = function(nodeID, nodeToConnect)
Graph.prototype.findNodeArray = function(nodeID)
Graph.prototype.areNodesConnected = function(nodeID, nodeIDMatch)

Graph.vertexExists(vert)	//checks if the specified vertex already exists within the nodes
							//returns the index of the node if it does exist
Graph.Length() 				//returns length of the nodeDictionary since it does not have a .length property