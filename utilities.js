//only works for native object types
function getType(obj){
	var tmp=Object.prototype.toString.call(obj);
	return tmp.slice(8,tmp.length-1);
}
//setup of XML Document
function loadXML(filename){
if (window.XMLHttpRequest)
  	{// code for IE7+, Firefox, Chrome, Opera, Safari
  	xmlhttp=new XMLHttpRequest();
  	}
else
  	{// code for IE6, IE5
  	xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  	}
  	
xmlhttp.open("GET",filename,false); //try to change this to true if possible
xmlhttp.send();
xmlDoc=xmlhttp.responseXML;
return xmlDoc;
}
//end of XML Document setup
function rng(min,max){
	return Math.floor(Math.random()*max+1)+min
}
function getDotProduct(dx1, dy1, dx2, dy2) {
    // normalise both vectors
    var l1 = Math.sqrt(dx1*dx1 + dy1*dy1),
          l2 = Math.sqrt(dx2*dx2 + dy2*dy2);
    if (l1==0 || l2==0) return 0;
    dx1 /= l1;
    dy1 /= l1;
    dx2 /= l2;
    dy2 /= l2;
    return dx1*dx2 + dy1*dy2;
  }