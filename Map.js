function Map(filename){
	this.mapGraph=new Graph();
	this.structureList=[];
	this.fuel;
	this.startPoint;
	if(filename){
		var xmlDoc=loadXML(filename);
		this.initNodes(xmlDoc);
		this.initStructures(xmlDoc);
	}
	else{
		var gen=new MapGenerator(0);
		this.mapGraph=gen.mapGraph;
		this.structureList=gen.structureList;
	}
}
Map.prototype.getEdgeList=function(){
	return this.mapGraph.getEdgeList();
}
Map.prototype.initNodes=function(xmlDoc){
	map=xmlDoc.getElementsByTagName("map")[0];
	var fuel=map.getElementsByTagName("fuel")[0];
	var num=fuel.getAttribute("numerator");
	var denom=fuel.getAttribute("denominator");
	this.fuel=new Fraction(num,denom);
	var start=map.getElementsByTagName("point")[0];
	var pos1=start.getAttribute("x");
	var pos2=start.getAttribute("y");
	this.startPoint=new Vertex(pos1,pos2);
	var roads=map.getElementsByTagName("road");
	var len=roads.length;
	for (var i = 0;i<len;i++){
		num=roads[i].getAttribute("numerator");
		denom=roads[i].getAttribute("denominator");
		pos1=new Vertex(roads[i].getElementsByTagName("point")[0].getAttribute("x"),
							roads[i].getElementsByTagName("point")[0].getAttribute("y"));
		pos2=new Vertex(roads[i].getElementsByTagName("point")[1].getAttribute("x"),
							roads[i].getElementsByTagName("point")[1].getAttribute("y"));
		var frac=new Fraction(roads[i].getAttribute("numerator"), roads[i].getAttribute("denominator"));
		
		var tmp=this.mapGraph.addNode(new Node(this.mapGraph.length.toString(),pos1.x,pos1.y));
		var tmp2=this.mapGraph.addNode(new Node(this.mapGraph.length.toString(),pos2.x,pos2.y));
		this.mapGraph.addConnection(tmp,tmp2,new Fraction(num,denom));
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