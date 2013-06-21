function Node(uID, x ,y){
    this.id = uID;
    this.vertex=new Vertex(x,y);
    this.connections={};
}
Node.prototype.position = function() {
    return this.vertex;
}

Node.prototype.equals = function(node) {
    var rv = false;

    if (this.id == node.id) {
        rv = true;
    }
    return rv;
}
Node.prototype.push=function(nodeId, weight){
	if(!this.existingConnection(nodeId)){
		this.connections[nodeId]=weight;
    }
}
Node.prototype.existingConnection=function(nodeId){
	if (this.connections[nodeId] != undefined)
        return true;
    return false;
}
