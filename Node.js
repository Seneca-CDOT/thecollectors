function node(struct, vertexID) {
    this.vertexID = vertexID;
    this.structure = struct;
}

node.prototype.position = function() {
    return this.vertexID;
}

node.prototype.containsStructure = function() {
    return this.structure > 0 ? true : false;
}

node.prototype.structure = function() {
    return this.structure;
}
node.prototype.equals = function(node) {
    var rv = false;
    if (this.vertexID == node.vertexID)
        rv = true;
    return rv;
}
