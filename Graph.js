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
    var check=this.vertexExists(node.vertex);
    if (node instanceof Node && check===false) {
        //this.nodeDictionary[node.id].push([node]);
        this.nodeDictionary[node.id]=node;
        var len = connectionIdList ? connectionIdList.length : 0;
        for (i = 0; i < len; i++) {
            // Push the new node into its connections' lists
            this.addConnections(connectionIdList[i], node);

            // Push the existing node connections into the new node's list
            this.addConnection(node.id, this.findNodeArray(connectionIdList[i])[0]);
        }
        return node.id;
    }
    else{
        return check;
    }
}

Graph.prototype.clearGraph = function() {
    this.nodeDictionary = {};
}

Graph.prototype.addConnection = function(nodeID, nodeToConnect) {
    var nodeArray = this.findNodeArray(nodeID);
    var nodeArray2= this.findNodeArray(nodeToConnect);

    if (nodeArray != undefined && nodeArray2 != undefined) {
        nodeArray.push(nodeToConnect);
        nodeArray2.push(nodeID);
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
Graph.prototype.getEdgeList=function(){
    var rvList={};
    for (index in this.nodeDictionary){

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
    var i=0;
    for (tmp in this.nodeDictionary){
        i++;
    }
    return i;
}