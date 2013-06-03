function Structure(nodeID, StructType, StructCaption, Points){
	this.visited=false;
}
Structure.prototype.position=function(){}					//returns the nodeID
Structure.prototype.getType=function(){}					//StructType will correspond with the filename for the icon
Structure.prototype.getCaption=function(){}					//StructCaption is the name of the individual structure
Structure.prototype.pointsString=function(){}				//returns Points as a string
//the get functions may be removed or modified since all variables are public