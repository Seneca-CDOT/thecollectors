StructureEnum = {
    NONE : 0,
    FUEL_STN : 1,
    OFFICE : 2,
    SCHOOL : 3
}

function NodeGraph() {
    this.nodeList = [];
    this.nodeListLength = 0;

    // Hash table of Node ID/index pairs
    this.nodeHashTable = {};
}

NodeGraph.prototype.addNode = function(node, connectionIdList) {
    if (this.nodeHashTable[node.id] != undefined) {
        console.warn("Node already exists in the graph. Duplicate attempt to add node terminated.");
        return;
    }
    if (connectionIdList && connectionIdList.indexOf(node.id) > -1) {
        console.warn("Attempt to add node to itself terminated.");
        return;
    }
    if (node instanceof Node) {
        this.nodeList.push([node]);
        this.nodeHashTable[node.id] = this.nodeListLength;
        this.nodeListLength += 1;

        var len = connectionIdList ? connectionIdList.length : 0;
        for (i = 0; i < len; i++) {
            // Push the new node into its connections' lists
            this.addConnections(connectionIdList[i], node);

            // Push the existing node connections into the new node's list
            this.addConnections(node.id, this.findNodeArray(connectionIdList[i])[0]);
        }
    }
}

NodeGraph.prototype.addEdge = function(edge) {
    var nodeArray = this.findNodeArray(edge.vertexOneID);
    nodeArray.push(edge);
    nodeArray = this.findNodeArray(edge.vertexTwoID);
    nodeArray.push(edge);
}

NodeGraph.prototype.clearGraph = function() {
    this.nodeList = [];
    this.nodeListLength = 0;
    this.nodeHashTable = {};
}

NodeGraph.prototype.addConnections = function(nodeID, nodeToConnect) {
    var nodeArray = this.findNodeArray(nodeID);

    if (nodeArray != undefined) {
        nodeArray.push(nodeToConnect);
    } else {
        console.error("Cannot add node connections. Node array not found!");
    }
}

NodeGraph.prototype.findNodeArray = function(nodeID) {
    return this.nodeList[this.nodeHashTable[nodeID]];
}

NodeGraph.prototype.areNodesConnected = function(nodeID, nodeIDToMatch) {
    if (nodeID == nodeIDToMatch) {
        console.warn("Node cannot be connected to itself.");
        return false;
    }

    var nodeArray = this.findNodeArray(nodeID);

    if (nodeArray != undefined) {
        var len = nodeArray.length;

        for (i = 1; i < len; i++) {
            if (nodeArray[i].id == nodeIDToMatch) {
                return true;
            }
        }

        return false;
    } else {
        console.error("Invalid NodeID. Node does not exist.");
    }
}
