function Node(struct, vertexID) {
    this.vertexID=vertexID;
    this.structure = struct;
}

Node.prototype.position = function() {
    return this.vertexID;
}

Node.prototype.containsStructure = function() {
    return this.structure > 0 ? true : false;
}

Node.prototype.structure = function() {
    return this.structure;
}
Node.prototype.equals = function(node){
	var rv=false;
	if (this.vertexID==node.vertexID)
		rv=true;
	return rv;
}
