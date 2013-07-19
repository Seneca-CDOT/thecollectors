function Structure(nodeID, StructType, customCaption, customPoints) {
    this.nodeID=nodeID;
    this.StructType=StructType;
    if(customCaption)
    	this.StructCaption=customCaption;
    else
    	this.StructCaption=StructureCaptions[StructType];
    if(customPoints)
    	this.Points=customPoints;
    else
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