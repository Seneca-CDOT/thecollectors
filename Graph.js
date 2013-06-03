function Graph() {
    // Dictionary of Node ID/Node Connection List pairs
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
        this.nodeDictionary[node.id].push([node]);

        var len = connectionIdList ? connectionIdList.length : 0;
        for (i = 0; i < len; i++) {
            // Push the new node into its connections' lists
            this.addConnections(connectionIdList[i], node);

            // Push the existing node connections into the new node's list
            this.addConnection(node.id, this.findNodeArray(connectionIdList[i])[0]);
        }
    }
}

Graph.prototype.clearGraph = function() {
    this.nodeDictionary = {};
}

Graph.prototype.addConnection = function(nodeID, nodeToConnect) {
    var nodeArray = this.findNodeArray(nodeID);

    if (nodeArray != undefined) {
        nodeArray.push(nodeToConnect);
    } else {
        console.error("Cannot add node connection. Node array not found!");
    }
}

Graph.prototype.findNodeArray = function(nodeID) {
    return this.nodeDictionary[nodeID];
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
