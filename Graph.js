function Graph() {
    // Dictionary of Node ID/Node Connection List pairs
    this.nodeDictionary = {};
    this.length=0;
}

Graph.prototype.addNode = function(node) {
    if (this.nodeDictionary[node.id] != undefined) {
        console.warn("Node already exists in the graph. Duplicate attempt to add node terminated.");
        return;
    }
    var check=this.vertexExists(node.vertex);
    if (node instanceof Node && check===false) {
        this.nodeDictionary[node.id]=node;
        this.length++;
        return node.id;
    }
    else{
        return check;
    }
}

Graph.prototype.clearGraph = function() {
    this.nodeDictionary = {};
    this.length=0;
}

Graph.prototype.addConnection = function(nodeID, nodeToConnect, weight) {
    var nodeArray = this.findNodeArray(nodeID);
    var nodeArray2= this.findNodeArray(nodeToConnect);

    if (nodeArray != undefined && nodeArray2 != undefined) {
        nodeArray.push(nodeToConnect,weight);
        nodeArray2.push(nodeID,weight);
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
Graph.prototype.vertexExists=function(vert){
    var rv=false;
    
    for (var index in this.nodeDictionary){
        if(this.nodeDictionary[index].vertex.equals(vert))
            rv=index;
    }
    return rv;
}
Graph.prototype.Length=function(){
    return this.length;
}