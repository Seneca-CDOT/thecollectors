function edge(id, vOne, vTwo, weight) {
    if (vOne == undefined || vTwo == undefined) {
        console.error("NodeIDs are undefined. Edge cannot be created.");
    }
    if (vOne == vTwo) {
        console.error("NodeIDs supplied are identical.");
    }
    if (weight < 0) {
        console.warn("Edge weight cannot be negative. Taking the absolute value.");
        weight = Math.abs(weight);
    }

    this.id = id;
    this.vertexOneID = vOne;
    this.vertexTwoID = vTwo;
    this.weight = weight;
}
edge.prototype.equals = function(edge) {
    var rv = false;
    if (this.vertexOneID == edge.vertexOneID && this.vertexTwoID == edge.vertexTwoID) {
        //&&this.weight==edge.weight)
        rv = true;
    }
    return rv;
}
