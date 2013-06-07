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