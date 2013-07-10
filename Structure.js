function Structure(nodeID, StructType) {
    this.nodeID=nodeID;
    this.StructType=StructType;
    this.StructCaption=StructCaptions[StructType];
    this.Points=StructureValues[StructType];
    this.visited=false;
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