function Node(uID, x ,y){
    this.id = uID;
    this.vertex=new Vertex(x,y);
    this.connections=[];
    this.connectionWeights=[];
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
		this.connections.push(nodeId.toString());
        this.connectionWeights.push(weight);
    }
}
Node.prototype.existingConnection=function(nodeId){
	var ln=this.connections.length;
	for(var i=0;i<ln;i++){
		if(this.connections[i]==nodeId.toString())
			return true;
        if(this.id==nodeId.toString())
            return true;
	}
	return false;
}
Node.prototype.removeConnection=function(nodeId){
    //wait until merge of connections array change
}