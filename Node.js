function Node(id, x, y, struct) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.structure = struct;
}

Node.prototype.position = function() {
    return [this.x, this.y];
}

Node.prototype.containsStructure = function() {
    return this.structure > 0 ? true : false;
}

Node.prototype.structure = function() {
    return this.structure;
}
