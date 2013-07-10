function Node(uID, x ,y){
    this.id = uID;
    this.vertex=new Vertex(x,y);
    this.connections={};
    this.connectionsLength=0;
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
        if (!weight) weight=1;
        this.connections[nodeId]=weight;
        this.connectionsLength++;
    }
}
Node.prototype.existingConnection=function(nodeId){
    if (this.connections[nodeId] != undefined)
        return true;
    if(this.id==nodeId.toString())
        return true;

	return false;
}
Node.prototype.removeConnection=function(nodeId){
    if(this.connections[nodeId]){
        delete this.connections[nodeId];
        this.connectionsLength--;
    }
}