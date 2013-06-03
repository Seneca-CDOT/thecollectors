function Structure(struct, vertexID) {
    this.vertexID=vertexID;
    this.struct = struct;
}

Structure.prototype.position = function() {
    return this.vertexID;
}

Structure.prototype.structure = function() {
    return this.struct;
}
Structure.prototype.equals = function(struct){
	var rv=false;
	if (this.vertexID==struct.vertexID)
		rv=true;
	return rv;
}