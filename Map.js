function Map(numStructs, difficulty, filename){
	this.mapGraph=new Graph();
	this.structureList=[];
    this.pjsStructureList={};
	this.fuel=new Fraction(0,0);
	this.startPoint;
    //if a filename exists, load the map from an XML file
	if(filename){
		var xmlDoc=loadXML(filename);
		this.initNodesFromXML(xmlDoc);
		this.initStructuresFromXML(xmlDoc);
	}
    //otherwise generate map using number of structures and difficulty
    //get the map's variable data from the map generator object
	else{
		var gen=new MapGenerator(numStructs,difficulty);
		this.mapGraph=gen.mapGraph;
		this.structureList=gen.structureList;
        this.fuel=new Fraction(gen.fuel,gen.fuel);
        this.startPoint=gen.startPoint;
        this.width=gen.maxWidth + rightPadding;
        this.height=gen.maxHeight + botPadding;
	}
}
/* 
    Returns the structure with the specified Id, or null if it doesn't exist.
*/
Map.prototype.getStructById=function(nodeID){
    for (var i = this.structureList.length - 1; i >= 0; i--) {
        if(this.structureList[i].nodeID == nodeID)
            return i;
    }
    return null;
}
Map.prototype.getEdgeList=function(){
	return this.mapGraph.getEdgeList();
}
/*  initializes nodes in the Graph object from an XML file
    using the <road> and <point> tags
    also initializes fuel tank value and startpoint 
*/
Map.prototype.initNodesFromXML=function(xmlDoc){
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
/*  fills the structure list from an XML file
    uses <place> tag
*/
Map.prototype.initStructuresFromXML=function(xmlDoc){
	var places=xmlDoc.getElementsByTagName("map")[0].getElementsByTagName("place");
	var len=places.length;
    for (var i = 0; i < len; i++) {
        var pos = new Vertex(places[i].getElementsByTagName("point")[0].getAttribute("x"),
        places[i].getElementsByTagName("point")[0].getAttribute("y"));
		var structType=places[i].getAttribute("type");
		var caption=places[i].getAttribute("caption");
		var points=parseInt(places[i].getAttribute("value"));
		nodeID=this.mapGraph.vertexExists(pos);
		this.structureList.push(new Structure(nodeID,structType,caption,points));
	}
}
/*
    Exports the map information into an XML string.
*/
Map.prototype.exportToXML = function() {
    var edgeList = this.getEdgeList(); // Contains the list node connections as indices
    var xmlWriter = new XMLWriter('UTF-8');
    var xmlString = null;

    // Set up XML document formatting
    xmlWriter.formatting = 'indented';
    xmlWriter.indentChar = ' ';
    xmlWriter.indentation = 4;

    // Start the XML string
    xmlWriter.writeStartDocument();
    xmlWriter.writeStartElement('maps');
    xmlWriter.writeStartElement('level');
    xmlWriter.writeStartElement('map');

    // Fuel
    xmlWriter.writeStartElement('fuel');
    xmlWriter.writeAttributeString('numerator', this.fuel.numerator.toString());
    xmlWriter.writeAttributeString('denominator', this.fuel.denominator.toString());
    xmlWriter.writeEndElement(); // fuel

    // Player starting location
    xmlWriter.writeStartElement('point');
    xmlWriter.writeAttributeString('x', this.startPoint.x.toString());
    xmlWriter.writeAttributeString('y', this.startPoint.y.toString());
    xmlWriter.writeEndElement(); // point

    // Roads list
    xmlWriter.writeStartElement('roads');
    for (var nodeIndex in edgeList) {
        // Get the first node that makes up the edge
        var node = this.mapGraph.nodeDictionary[nodeIndex];
        // Get the list of node indices that refer to nodes connected to the first node
        var connectionArray = edgeList[nodeIndex];

        for (var connectionIndex = 0; connectionIndex < connectionArray.length; connectionIndex++) {
            // Get the node that is connected to the first node, making up the edge
            var connectedNode = this.mapGraph.nodeDictionary[connectionArray[connectionIndex]];
            // Get the Fraction for the edge made up of the two nodes
            var edgeWeight = node.connections[connectionArray[connectionIndex]];

            // Road segment
            xmlWriter.writeStartElement('road');
            xmlWriter.writeAttributeString('numerator', edgeWeight.numerator.toString());
            xmlWriter.writeAttributeString('denominator', edgeWeight.denominator.toString());

            // Start coordinates of road segment
            xmlWriter.writeStartElement('point');
            xmlWriter.writeAttributeString('x', node.vertex.x.toString());
            xmlWriter.writeAttributeString('y', node.vertex.y.toString());
            xmlWriter.writeEndElement(); // point

            // End coordinates of road segment
            xmlWriter.writeStartElement('point');
            xmlWriter.writeAttributeString('x', connectedNode.vertex.x.toString());
            xmlWriter.writeAttributeString('y', connectedNode.vertex.y.toString());
            xmlWriter.writeEndElement(); // point

            xmlWriter.writeEndElement(); // road
        }
    }
    xmlWriter.writeEndElement(); // roads

    // Places list
    xmlWriter.writeStartElement('places');
    for (var structIndex = 0; structIndex < this.structureList.length; structIndex++) {
        // Get a Structure object
        var structure = this.structureList[structIndex];
        // Get the node associated with the Structure object
        var structNode = this.mapGraph.nodeDictionary[structure.nodeID];

        // Place
        xmlWriter.writeStartElement('place');
        xmlWriter.writeAttributeString('type', structure.StructType);
        xmlWriter.writeAttributeString('caption', structure.StructCaption);
        xmlWriter.writeAttributeString('value', structure.Points);

        // Coordinates of the Place
        xmlWriter.writeStartElement('point');
        xmlWriter.writeAttributeString('x', structNode.vertex.x.toString());
        xmlWriter.writeAttributeString('y', structNode.vertex.y.toString());
        xmlWriter.writeEndElement(); // point

        xmlWriter.writeEndElement(); // place
    }
    xmlWriter.writeEndElement(); // places

    xmlWriter.writeEndElement(); // map
    xmlWriter.writeEndElement(); // level
    xmlWriter.writeEndElement(); // maps
    xmlWriter.writeEndDocument();

    xmlString = xmlWriter.flush().substr(40);
    xmlWriter.close();

    return xmlString;
}
