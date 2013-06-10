var sizex=940, sizey=640, baseDistance=60;
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
	var node=new Node(this.index++,rng(10,sizex/10+10),rng(10,sizey/10+10)); 				//940-640
	var check=this.mapGraph.addNode(node);
	var cap=50;
	for(var i=1; i<=cap;i++){	
		var x,y, distance=rng(0,9);
		switch(distance){
			case 0:
				distance=baseDistance*4;
				break;
			case 1:
				distance=baseDistance*3;
				break;
			case 2:
			case 3:
				distance=baseDistance*2;
				break;
			default:
				distance=baseDistance;
		}
		var heading=rng(0,4);
		switch(heading){
			case 0:
			case 1:
				x=node.vertex.x;
				y=node.vertex.y-distance;
				if(y<35)
					heading=rng(2,4);
				else	
					break;
			case 2:
				x=node.vertex.x;
				y=node.vertex.y+distance;
				//if(y>=sizey)
				//	y-=distance*2;
				break;
			case 3:
				x=node.vertex.x-distance;
				y=node.vertex.y;
				if(x<35){
					heading=4;
					
				}
				else
					break;
			case 4:
			
				x=node.vertex.x+distance;
				y=node.vertex.y;
				break;
		}
		var node2=new Node(this.index,x,y);

		var tmp=this.mapGraph.addNode(node2);
		if(tmp!= i)
			cap++;
		this.mapGraph.addConnection(tmp,check);
		check=tmp;
		this.index++;
		node=node2;
	}
}