function map(xmldoc){
	this.vertexBuffer=new vertexIndex();
	this.edgeBuffer=new edgeIndex();
	this.nodeBuffer=new nodeIndex();
	
	this.initEdges(xmlDoc);
	this.initNodes(xmlDoc);
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
		this.edgeBuffer.add(new Edge(frac,this.vertexBuffer.add(pos1),this.vertexBuffer.add(pos2)));
	}

}
map.prototype.initNodes=function(xmlDoc){
	var places=xmlDoc.getElementsByTagName("map")[0].getElementsByTagName("place");
	var len=places.length;


	for (var i = 0; i <len; i++) {
		var pos=new vertex(	places[i].getElementsByTagName("point")[0].getAttribute("x"),
							places[i].getElementsByTagName("point")[0].getAttribute("y"));

		places[i].getElementsByTagName("point")[0];
		var z=this.nodeBuffer.add(new Node(places[i].getAttribute("type"), this.vertexBuffer.add(pos)));
		z=this.nodeBuffer.getNode(z).position();
		this.vertexBuffer.getVertex(z).empty=false;
	};
}