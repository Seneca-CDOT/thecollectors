function Node(uID, x ,y){
    this.id = uID;
    this.vertex=new Vertex(x,y);
    this.connections=[];
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
Node.prototype.push=function(nodeId){
	if(!this.existingConnection(nodeId))
		this.connections.push(nodeId);
}
Node.prototype.existingConnection=function(nodeId){
	var ln=this.connections.length;
	for(var i=0;i<ln;i++){
		if(this.connections[i]==nodeId)
			return true;
	}
	return false;
}
