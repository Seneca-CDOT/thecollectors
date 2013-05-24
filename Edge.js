function Edge(frac, vOne, vTwo) {
    this.vertexOneID = vOne;
    this.vertexTwoID = vTwo;
    this.weight = frac;
}
Edge.prototype.equals=function(edge){
	var rv=false;	
	if(this.vertexOneID==edge.vertexOneID&&this.vertexTwoID==edge.vertexTwoID)
		//&&this.weight==edge.weight)
		rv = true;
	return rv;
}