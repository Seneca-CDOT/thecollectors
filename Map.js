function Map(mapGraph,structureList,filename){
	this.mapGraph=new Graph();
	this.structureList=[];
	if(filename){
		var xmlDoc=loadXML(filename);
		this.initNodes(xmlDoc);
		this.initStructures(xmlDoc);
		console.log(this.mapGraph);
	}
	else{
		this.mapGraph=mapGraph;
		this.structureList=structureList;
	}
}

Map.prototype.getEdgeList=function(){
	var matrix={};

	return matrix;
}


/*************			Legacy XML Reading Code to be Updated for Graph Implementation 			**********/
/*function Map(filename){
	this.vertexBuffer=new VertexIndex();
	this.edgeBuffer=new EdgeIndex();
	this.StructureBuffer=new StructureIndex();
	var xmlDoc=loadXML(fileName);
	this.initEdges(xmlDoc);
	this.initStructures(xmlDoc);
}*/
Map.prototype.initNodes=function(xmlDoc){
	var roads=xmlDoc.getElementsByTagName("map")[0].getElementsByTagName("road");
	var len=roads.length;
	for (var i = 0;i<len;i++){
		var pos1=new Vertex(roads[i].getElementsByTagName("point")[0].getAttribute("x"),
							roads[i].getElementsByTagName("point")[0].getAttribute("y"));
		var pos2=new Vertex(roads[i].getElementsByTagName("point")[1].getAttribute("x"),
							roads[i].getElementsByTagName("point")[1].getAttribute("y"));
		var frac=new Fraction(roads[i].getAttribute("numerator"), roads[i].getAttribute("denominator"));
		
		var tmp=this.mapGraph.addNode(new Node(this.mapGraph.Length().toString(),pos1.x,pos1.y));
		var tmp2=this.mapGraph.addNode(new Node(this.mapGraph.Length().toString(),pos2.x,pos2.y));
		this.mapGraph.addConnection(tmp,tmp2);
    }
}
Map.prototype.initStructures=function(xmlDoc){
	var places=xmlDoc.getElementsByTagName("map")[0].getElementsByTagName("place");
	var len=places.length;
    for (var i = 0; i < len; i++) {
        var pos = new Vertex(places[i].getElementsByTagName("point")[0].getAttribute("x"),
        places[i].getElementsByTagName("point")[0].getAttribute("y"));
		var structType=places[i].getAttribute("type");
		var caption=places[i].getAttribute("caption");
		var points=places[i].getAttribute("value");
		nodeID=this.mapGraph.vertexExists(pos);
		this.structureList.push(new Structure(nodeID,structType,caption,points));

	}
}