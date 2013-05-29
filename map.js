function Map(fileName){
	this.vertexBuffer=new VertexIndex();
	this.edgeBuffer=new EdgeIndex();
	this.StructureBuffer=new StructureIndex();
	var xmlDoc=loadXML(fileName);
	this.initEdges(xmlDoc);
	this.initStructures(xmlDoc);
}
Map.prototype.initEdges=function(xmlDoc){
	var roads=xmlDoc.getElementsByTagName("map")[0].getElementsByTagName("road");
	var len=roads.length;
	for (var i = 0;i<len;i++){
		var pos1=new Vertex(roads[i].getElementsByTagName("point")[0].getAttribute("x"),
							roads[i].getElementsByTagName("point")[0].getAttribute("y"));
		var pos2=new Vertex(roads[i].getElementsByTagName("point")[1].getAttribute("x"),
							roads[i].getElementsByTagName("point")[1].getAttribute("y"));
		var frac=new Fraction(roads[i].getAttribute("numerator"), roads[i].getAttribute("denominator"));
		this.edgeBuffer.add(new Edge(frac,this.vertexBuffer.add(pos1),this.vertexBuffer.add(pos2)));
    }
}
Map.prototype.initStructures=function(xmlDoc){
	var places=xmlDoc.getElementsByTagName("map")[0].getElementsByTagName("place");
	var len=places.length;
    for (var i = 0; i < len; i++) {
        var pos = new Vertex(places[i].getElementsByTagName("point")[0].getAttribute("x"),
        places[i].getElementsByTagName("point")[0].getAttribute("y"));
		places[i].getElementsByTagName("point")[0];
		var z=this.StructureBuffer.add(new structure(places[i].getAttribute("type"), this.vertexBuffer.add(pos)));
		z=this.StructureBuffer.getStructure(z).position();
		this.vertexBuffer.getVertex(z).empty=false;
	}
}

