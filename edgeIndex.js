function edgeIndex(){
	this.edgeList= new Array();
}
edgeIndex.prototype.add = function(edge) {
	var check=this.getIndex(edge);
	
	if(check >=0)
		return check;
	else
		return this.edgeList.push(edge) - 1;
}
edgeIndex.prototype.remove = function(edge){
	var check=this.getIndex(edge);
	if (check >= 0){
		this.edgeList.splice(check,1);
	}
}
edgeIndex.prototype.getEdge = function(index){
	return this.edgeList[index];
}

edgeIndex.prototype.getIndex = function(edge){
	var len=this.edgeList.length;
	for(var i=0; i < len; i++){
		if(this.edgeList[i].equals(edge))
			return i;
	}
	return -1;
}
edgeIndex.prototype.getLength = function(){
	return this.edgeList.length;
}