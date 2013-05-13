//only works for native object types
function getType(obj){
	var tmp=Object.prototype.toString.call(obj);
	return tmp.slice(8,tmp.length-1);
}
