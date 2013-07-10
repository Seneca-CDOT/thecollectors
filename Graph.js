function Graph() {
    // Dictionary of Node ID/Node Connection List pairs
    this.nodeDictionary = {};
    this.length=0;
}
Graph.prototype.addNode = function(node) {
    if (this.nodeDictionary[node.id] != undefined) {
        //console.warn("Node already exists in the graph. Duplicate attempt to add node terminated.");
        return node.id;
    }
    var check=this.vertexExists(node.vertex);
    if (node instanceof Node && check===false) {
        this.nodeDictionary[node.id.toString()]=node;
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
Graph.prototype.removeConnection = function (node1, node2){
    this.nodeDictionary[node1].removeConnection(node2);
    this.nodeDictionary[node2].removeConnection(node1);
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
        if(nodeArray.connections[nodeIDToMatch]){
            return true;
        }
        else return false;
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
Graph.prototype.edgeIntersects=function(x1,y1,x2,y2){
    var rvList=[];
    var edges=this.getEdgeList();

    for(index in edges){
        var vert1=this.nodeDictionary[index].vertex;
        for (var i = edges[index].length - 1; i >= 0; i--) {
            var vert2=this.nodeDictionary[edges[index][i]].vertex;
            var check=segIntersection(vert1.x,vert1.y,vert2.x,vert2.y,x1,y1,x2,y2);
            if(check){
                rvList.push(check);
            }
        }
    }
    return rvList;
}
Graph.prototype.getEdgeList=function(){
    var matrix= {};
    var graphList=this.nodeDictionary; 
    for (index in graphList) {
        matrix[index]= [];
        for (i in graphList[index].connections){
            if(!matrix[i]){
                matrix[index].push(i);
            }
        }
    }
    return matrix;
}
Graph.prototype.Length=function(){
    return this.length;
}