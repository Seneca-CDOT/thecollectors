var sizex=940, sizey=640, baseDistance=60;
function MapGenerator(difficulty){
	this.mapGraph=new Graph();
	this.structureList={};
	this.index=0;
	this.generateMapGraph();
}
MapGenerator.prototype.generateMapGraph = function() {
	this.generateRoads();
	this.cleanNodes();
}
MapGenerator.prototype.generateRoads = function(){
	var node=new Node(this.index++,rng(10,sizex/10+10),rng(10,sizey/10+10));
	var nodeID=this.mapGraph.addNode(node);
	var cap=20, prevHeading=0, prevDistance=0;
	for(var i=1; i<=cap;i++){	
		var x,y, distance=rng(0,6);
		distance-=prevDistance;
		if(distance < 0) distance*= -1;
		prevDistance=distance;
		
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
		if(prevHeading==1)
			var heading=rng(3,5);
		else if(prevHeading==2)
			var heading=rng(0,2);
		else
			var heading=rng(0,5);
		if(heading<3) prevHeading=1;
		else prevHeading=2;
		switch(heading){
			case 0:
			case 1:
				x=node.vertex.x;
				y=node.vertex.y-distance;
				if(y<35)
					heading=2;
				else	
					break;
			case 2:
				x=node.vertex.x;
				y=node.vertex.y+distance;
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
			case 5:
				x=node.vertex.x+distance;
				y=node.vertex.y;
				break;
		}
		var node2=new Node(this.index,x,y);
		var node2ID=this.mapGraph.addNode(node2);
		if(node2ID == i)
			this.index++;
		else
			i--;
/*
		var intersectCheck=this.mapGraph.edgeIntersects(node.vertex.x,node.vertex.y,node2.vertex.x,node2.vertex.y);
		var ln=intersectCheck.length;
		if(ln == 0)
		{	this.mapGraph.addConnection(node2ID,nodeID);	}
		else{
			for (var j=0;j<ln;j++){
				var ret=intersectCheck[j];
				if (ret.colinear){
					this.mapGraph.addConnection(node2ID,nodeID);
				}
				else {
					var intNode=new Node(this.index,ret.x,ret.y);
					intNode=this.mapGraph.addNode(intNode);
					var tmpvert1=new Vertex(ret.x1,ret.y1);
					var tmpvert2=new Vertex(ret.x2,ret.y2);
					var rv1=this.mapGraph.vertexExists(new Vertex(ret.x1,ret.y1));
					var rv2=this.mapGraph.vertexExists(new Vertex(ret.x2,ret.y2));
					this.mapGraph.removeConnection(rv1,rv2);
					if(intNode == i+1){ 					//a new node was added		
						this.mapGraph.addConnection(rv1,intNode);
						this.mapGraph.addConnection(rv2,intNode);
						this.mapGraph.addConnection(node2ID,intNode);
						this.mapGraph.addConnection(nodeID,intNode);
						this.index++;
						i++; cap++;
					}
					else {							//connected with an existing node
						var connectTo=intNode;
						if(intNode==nodeID){
							connectTo=nodeID;
						}
						else if (intNode==node2ID){
							connectTo=node2ID;
						}
						
						this.mapGraph.addConnection(rv1,connectTo);
						this.mapGraph.addConnection(rv2,connectTo);	
						if(intNode==connectTo){
							this.mapGraph.addConnection(node2ID,intNode);
							this.mapGraph.addConnection(nodeID,intNode);							
						}
						else this.mapGraph.addConnection(node2ID,nodeID);
					}
				}
			}
		}
*/		this.mapGraph.addConnection(node2ID,nodeID);
		nodeID=node2ID; 
		node=node2;
	}
}
MapGenerator.prototype.cleanNodes = function(){
	var nodes=this.mapGraph.nodeDictionary;
	var edges=this.mapGraph.getEdgeList();
	var tmpGraph= new Graph();
	var j=0;
	for(indekkusu in edges){
		var node1=nodes[indekkusu];
		for (var i = edges[indekkusu].length - 1; i >= 0; i--) {
			var node2=nodes[edges[indekkusu][i]];
			var intersectCheck=this.mapGraph.edgeIntersects(node1.vertex.x,node1.vertex.y,node2.vertex.x,node2.vertex.y)
			if(intersectCheck){
				
				var node1ID=new Node(j++, node1.vertex.x, node1.vertex.y);
				node1ID=tmpGraph.addNode(node1ID);
				var node2ID=new Node(j++, node2.vertex.x, node2.vertex.y);
				node2ID=tmpGraph.addNode(node2ID);
				for (var i = intersectCheck.length - 1; i >= 0; i--) {
					if(!intersectCheck[i].colinear){
						var intNode=new Node(j++, intersectCheck[i].x, intersectCheck[i].y);
						intNode=tmpGraph.addNode(intNode);
						var node3=new Node(j++, intersectCheck[i].x1, intersectCheck[i].y1);
						node3=tmpGraph.addNode(node3);
						var node4=new Node(j++, intersectCheck[i].x2, intersectCheck[i].y2);
						node4=tmpGraph.addNode(node4);
						tmpGraph.addConnection(intNode,node1ID);
						tmpGraph.addConnection(intNode,node2ID);
						tmpGraph.addConnection(intNode,node3);
						tmpGraph.addConnection(intNode,node4);
						var tmpNodes=tmpGraph.nodeDictionary;
					}
				}
				
			}
		}
	}
	nodes=tmpGraph.nodeDictionary;
	for(index in nodes){
		var node1=nodes[index];
		for(indx in node1.connections){
			var node2=nodes[indx];
			for(indekkusu in node1.connections){
				if(indx != indekkusu){
					var node3=nodes[indekkusu];
					var intersectCheck=segIntersection(node1.vertex.x, node1.vertex.y,
														node2.vertex.x, node2.vertex.y,
														node1.vertex.x, node1.vertex.y,
														node3.vertex.x, node3.vertex.y);
					if(intersectCheck.colinear){
						var dist1=distance(node1.vertex,node2.vertex);
						var dist2=distance(node1.vertex,node3.vertex);
						if(node1.vertex.extendedSlope(node2.vertex) == node1.vertex.extendedSlope(node3.vertex)){
							if(dist1<dist2){
								tmpGraph.removeConnection(node1.id, node3.id);
							}
							else{
								tmpGraph.removeConnection(node1.id, node2.id);
							}
						}
					}
				}
			}
		}
	}
	this.mapGraph=tmpGraph;
}