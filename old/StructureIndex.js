function StructureIndex(){
	this.StructureList= new Array();
}
StructureIndex.prototype.add = function(Struct) {
	var check=this.getIndex(Struct);
	
	if(check >=0)
		return check;
	else
		return this.StructureList.push(Struct) - 1;
}
StructureIndex.prototype.remove = function(Struct){
	var check=this.getIndex(Struct);
	if (check >= 0){
		this.StructureList.splice(check,1);
	}
}
StructureIndex.prototype.getStructure = function(index){
	return this.StructureList[index];
}
StructureIndex.prototype.getIndex = function(Struct){
	var len=this.StructureList.length;
	for(var i=0; i < len; i++){
		if(this.StructureList[i].equals(Struct))
			return i;
	}
	return -1;
}
StructureIndex.prototype.getLength = function(){
	return this.StructureList.length;
}