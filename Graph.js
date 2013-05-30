function Graph() {
    this.nodeList = [];

    // Dictionary of Node ID/index pairs
    this.nodeDictionary = {};
}

Graph.prototype.addNode = function(node, connectionIdList) {
    if (this.nodeDictionary[node.id] != undefined) {
        console.warn("Node already exists in the graph. Duplicate attempt to add node terminated.");
        return;
    }
    if (connectionIdList && connectionIdList.indexOf(node.id) > -1) {
        console.warn("Attempt to add node to itself terminated.");
        return;
    }
    if (node instanceof Node) {
        this.nodeList.push([node]);
        this.nodeDictionary[node.id] = this.nodeList.length;

        var len = connectionIdList ? connectionIdList.length : 0;
        for (i = 0; i < len; i++) {
            // Push the new node into its connections' lists
            this.addConnections(connectionIdList[i], node);

            // Push the existing node connections into the new node's list
            this.addConnections(node.id, this.findNodeArray(connectionIdList[i])[0]);
        }
    }
}

Graph.prototype.clearGraph = function() {
    this.nodeList = [];
    this.nodeListLength = 0;
    this.nodeDictionary = {};
}

Graph.prototype.addConnections = function(nodeID, nodeToConnect) {
    var nodeArray = this.findNodeArray(nodeID);

    if (nodeArray != undefined) {
        nodeArray.push(nodeToConnect);
    } else {
        console.error("Cannot add node connections. Node array not found!");
    }
}

Graph.prototype.findNodeArray = function(nodeID) {
    return this.nodeList[this.nodeDictionary[nodeID]];
}

Graph.prototype.areNodesConnected = function(nodeID, nodeIDToMatch) {
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
