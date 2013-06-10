function MapGenerator(difficulty){
	this.mapGraph=new Graph();
	this.structureList={};
	this.stack=[];
	this.index=0;
	this.generateMapGraph();
}
MapGenerator.prototype.generateMapGraph = function() {
	this.generateRoads();
}
MapGenerator.prototype.generateRoads = function(){
	var node=new Node(this.index++,rng(1,939),rng(1,639)); 				//940-540
	var check=this.mapGraph.addNode(node);
	for(var i=0; i<50;i++){
		var heading=rng(0,3);
		var x,y;
		switch(heading){
			case 0:
				x=node.vertex.x;
				y=node.vertex.y-50;
				break;
			case 1:
				x=node.vertex.x;
				y=node.vertex.y+50;
				break;
			case 2:
				x=node.vertex.x-50;
				y=node.vertex.y;
				break;
			case 3:
				x=node.vertex.x+50;
				y=node.vertex.y;
				break;
		}
		var node2=new Node(this.index,x,y);

		var tmp=this.mapGraph.addNode(node2);
		this.mapGraph.addConnection(node2,check);
		check=tmp;
		this.index++;
		node=node2;
	}
}