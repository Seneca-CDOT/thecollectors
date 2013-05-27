function vertexIndex() {
    this.vertexList = [];
}

vertexIndex.prototype.add = function(vert) {
    var check = this.getIndex(vert);

    if (check >= 0) {
		return check;
    } else {
        return this.vertexList.push(vert) - 1;
    }
}

vertexIndex.prototype.remove = function(vert) {
    var check = this.getIndex(vert);
    if (check >= 0) {
        this.vertexList.splice(check, 1);
    }
}

vertexIndex.prototype.getVertex = function(index) {
    return this.vertexList[index];
}

// Pass a vertex object. Returns the index of that vertex, or -1 if it doesn't exist.
vertexIndex.prototype.getIndex = function(vert) {
    var len = this.vertexList.length;
    for (var i = 0; i < len; i++) {
        if (this.vertexList[i].equals(vert)) {
            return i;
        }
    }
    return -1;
}
