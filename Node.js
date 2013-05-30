function Node(uID, vPosition) {
    this.id = uID;
    this.vertexPosition = vPosition;
}

Node.prototype.position = function() {
    return this.vertexPosition;
}

Node.prototype.equals = function(node) {
    var rv = false;

    if (this.id == node.id) {
        rv = true;
    }
    return rv;
}
