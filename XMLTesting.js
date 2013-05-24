function node(desc,pos){
	this.desc=desc;
	this.pos=pos;
}
function edge(frac,pos1,pos2){
	this.weight=frac;
	this.pos1=pos1;
	this.pos2=pos2;
}
function map(){
	this.edges=new Array();
	this.nodes=new Array();
}
map.prototype.initEdges=function(xmldoc){
	var roads=xmlDoc.getElementsByTagName("map")[0].getElementsByTagName("road");
	var len=roads.length;
	for (var i = 0;i<len;i++){
		var pos1=new vertex(roads[i].getElementsByTagName("point")[0].getAttribute("x"),
							roads[i].getElementsByTagName("point")[0].getAttribute("y"));
		var pos2=new vertex(roads[i].getElementsByTagName("point")[1].getAttribute("x"),
							roads[i].getElementsByTagName("point")[1].getAttribute("y"));
		var frac=new fraction(roads[i].getAttribute("numerator"), roads[i].getAttribute("denominator"));
		this.edges[i]=new edge(frac,pos1,pos2);
	}

}
map.prototype.initNodes=function(xmlDoc){
	var places=xmlDoc.getElementsByTagName("map")[0].getElementsByTagName("place");
	var len=places.length;
	for (var i = 0; i <len; i++) {
		var tempPos=places[i].getElementsByTagName("point")[0];
		this.nodes[i]=new node(places[i].getAttribute("type"),new vertex(tempPos.getAttribute("x"),tempPos.getAttribute("y")));
	};
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
var xmldoc=loadXML("map.xml");
var map1= new map();
map1.initNodes(xmlDoc);
map1.initEdges(xmlDoc);
console.log(map1);