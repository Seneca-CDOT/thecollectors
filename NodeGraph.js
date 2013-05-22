StructureEnum = {
    NONE : 0,
    FUEL_STN : 1,
    OFFICE : 2,
    SCHOOL : 3
}

function NodeGraph() {
    this.nodeList = [];
    this.edgeList = [];
    this.nodeLength = 0;
    this.edgeLength = 0;

    // hash table of Node ID/index pairs
    this.nodeHashTable = {};
}

NodeGraph.prototype.addNode = function(node, connectionIdList) [
    if (node instanceof Node) {
        this.nodeList.push([node]);
        this.nodeHashTable[node.id] = this.nodeLength;
        this.nodeLength += 1;

        var len = connectionIdList.length;
        for (i = 0; i < len; i++) {
            // Push the new node into its connections' lists
            NodeGraph.addConnections(connectionIdList[i], node);

            // Push the existing node connections into the new node's list
            NodeGraph.addConnections(node.id, NodeGraph.findNodeArray(connectionIdList[i])[0]);
        }
    }
}

NodeGraph.prototype.addConnections = function(nodeID, nodesToConnect) {
    var nodeArray = NodeGraph.findNodeArray(nodeID);

    if (nodeArray != undefined) {
        var len = nodesToConnect.length;
        for (i = 0; i < len; i++) {
            nodeArray.push(nodesToConnect[i]);
        }
    }
}

NodeGraph.prototype.findNodeArray = function(nodeID) {
    return this.nodeList[this.nodeHashTable[nodeID]];
}
