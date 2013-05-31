function Structure(nodeID, StructType, StructCaption, Points) {
    this.nodeID=nodeID;
    this.StructType=StructType;
    this.StructCaption=StructCaption;
    this.Points=Points;
}
Structure.prototype.position = function() {
    return this.nodeID;
}
Structure.prototype.getType = function() {
    return this.StructType;
}
Structure.prototype.getCaption = function(){
	return this.StructCaption;
}
Structure.prototype.pointsString = function(){
	return this.Points.toString();
}
Structure.prototype.equals = function(struct){
	var rv=false;
	if (this.nodeID==struct.nodeID)
		rv=true;
	return rv;
}