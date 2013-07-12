var sizex=940, sizey=640, baseDistance=100;
function MapGenerator(numStructs, difficulty){
	this.mapGraph=new Graph();
	this.structureList=[];
	this.index=0;
	this.numStructs=numStructs;
	var pool=DenominatorPool.easy;
	if(difficulty == 2 || difficulty == 3){
		pool=pool.concat(DenominatorPool.normal);
		if(difficulty == 3)
			pool=pool.concat(DenominatorPool.hard);	
	}
	this.fuel=pool[rng(0,pool.length-1)];
	//this.fuel=new Fraction(fuel,fuel);
	this.generateMapGraph();
}
MapGenerator.prototype.generateMapGraph = function() {
	this.generateRoads();
	this.cleanNodes();
	this.generateStructures();
}
MapGenerator.prototype.generateRoads = function(){
	var node=new Node(this.index++,rng(50,sizex/5),rng(50,sizey/5));
	var nodeID=this.mapGraph.addNode(node);
	var cap=this.numStructs*3, prevHeading=0, prevDistance=0;
	var distanceCap=Math.round(this.fuel / 2);
	for(var i=1; i<=cap;i++){	
		var x,y, distance=rng(1,distanceCap);
		distance=baseDistance*distance;
		if(prevHeading==1)
			var heading=rng(5,8);
		else if(prevHeading==2)
			var heading=rng(0,4);
		else
			var heading=rng(0,8);
		if(heading<5) prevHeading=1;
		else prevHeading=2;
		switch(heading){
			case 0:
			case 1:
			case 2:
				x=node.vertex.x;
				y=node.vertex.y-distance;
				if(y<50)
					heading=3;
				else	
					break;
			case 3:
			case 4:
				x=node.vertex.x;
				y=node.vertex.y+distance;
				break;
			case 5:
			case 6:
				x=node.vertex.x-distance;
				y=node.vertex.y;
				if(x<50){
					heading=7;
				}
				else
					break;
			case 7:
			case 8:
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
		this.mapGraph.addConnection(node2ID,nodeID);
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
						var tmpNodes=tmpGraph.nodeDictionary;
						tmpGraph.addConnection(intNode,node1ID, 
							new Fraction(distance(tmpNodes[intNode].vertex,tmpNodes[node1ID].vertex)/baseDistance,this.fuel));
						tmpGraph.addConnection(intNode,node2ID,
							new Fraction(distance(tmpNodes[intNode].vertex,tmpNodes[node2ID].vertex)/baseDistance,this.fuel));
						tmpGraph.addConnection(intNode,node3,
							new Fraction(distance(tmpNodes[intNode].vertex,tmpNodes[node3].vertex)/baseDistance,this.fuel));
						tmpGraph.addConnection(intNode,node4,
							new Fraction(distance(tmpNodes[intNode].vertex,tmpNodes[node4].vertex)/baseDistance,this.fuel));
						
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
								/*tmpGraph.removeConnection(node1.id, node2.id);
								tmpGraph.addConnection(node1.id,node3.id,
									new Fraction(distance(node1.vertex,node3.vertex)/baseDistance,this.fuel));*/
							}
						}
					}
				}
			}
		}
	}
	this.mapGraph=tmpGraph;
}
MapGenerator.prototype.generateStructures = function(){
	
}