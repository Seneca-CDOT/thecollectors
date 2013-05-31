function Node(uID, vertex) {
    this.id = uID;
    this.vertex = vertex;
}

Node.prototype.position = function() {
    return this.vertex;
}

Node.prototype.equals = function(node) {
    var rv = false;

    if (this.id == node.id) {
        rv = true;
    }
    if (this.vertex.equals(node.vertex)){
    	rv = true;
    }
    return rv;
}
