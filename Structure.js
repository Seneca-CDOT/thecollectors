function structure(struct, vertexID) {
    this.vertexID=vertexID;
    this.struct = struct;
}

structure.prototype.position = function() {
    return this.vertexID;
}

structure.prototype.structure = function() {
    return this.struct;
}
structure.prototype.equals = function(struct){
	var rv=false;
	if (this.vertexID==struct.vertexID)
		rv=true;
	return rv;
}