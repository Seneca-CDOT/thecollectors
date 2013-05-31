function EdgeIndex() {
    this.edgeList = [];
}

EdgeIndex.prototype.add = function(edge) {
    var check = this.getIndex(edge);

    if (check >= 0) {
        return check;
    } else {
        return this.edgeList.push(edge) - 1;
    }
}

EdgeIndex.prototype.remove = function(edge) {
    var check = this.getIndex(edge);
    if (check >= 0) {
        this.edgeList.splice(check, 1);
    }
}

EdgeIndex.prototype.getEdge = function(index) {
    return this.edgeList[index];
}
EdgeIndex.prototype.getIndex = function(edge){
	var len=this.edgeList.length;
	for(var i=0; i < len; i++){
		if(this.edgeList[i].equals(edge))
			return i;
	}
	return -1;
}
EdgeIndex.prototype.getLength = function(){
	return this.edgeList.length;
}