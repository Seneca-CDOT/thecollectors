function VertexIndex() {
    this.vertexList = [];
}

VertexIndex.prototype.add = function(vert) {
    var check = this.getIndex(vert);

    if (check >= 0) {
        return check;
    } else {
        return this.vertexList.push(vert) - 1;
    }
}

VertexIndex.prototype.remove = function(vert) {
    var check = this.getIndex(vert);
    if (check >= 0) {
        this.vertexList.splice(check, 1);
    }
}

VertexIndex.prototype.getVertex = function(index) {
    return this.vertexList[index];
}

// Pass a vertex object. Returns the index of that vertex, or -1 if it doesn't exist.
VertexIndex.prototype.getIndex = function(vert) {
    var len = this.vertexList.length;
    for (var i = 0; i < len; i++) {
        if (this.vertexList[i].equals(vert)) {
            return i;
        }
    }
    return -1;
}
VertexIndex.prototype.getLength = function(){
    return this.vertexList.length;
}