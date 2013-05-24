function nodeIndex(){
	this.nodeList= new Array();
}
nodeIndex.prototype.add = function(node) {
	var check=this.getIndex(node);
	
	if(check >=0)
		return check;
	else
		return this.nodeList.push(node) - 1;
}
nodeIndex.prototype.remove = function(node){
	var check=this.getIndex(node);
	if (check >= 0){
		this.nodeList.splice(check,1);
	}
}
nodeIndex.prototype.getNode = function(index){
	return this.nodeList[index];
}
nodeIndex.prototype.getIndex = function(node){
	var len=this.nodeList.length;
	for(var i=0; i < len; i++){
		if(this.nodeList[i].equals(node))
			return i;
	}
	return -1;
}
