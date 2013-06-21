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
	this.cleanNodes();
}
MapGenerator.prototype.generateRoads = function(){
	var node=new Node(this.index++,rng(10,sizex/10+10),rng(10,sizey/10+10));
	var nodeID=this.mapGraph.addNode(node);
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
		var node2ID=this.mapGraph.addNode(node2);
		if(node2ID == i)
			this.index++;
		else
			i--;

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
						console.log(nodeID, node2ID ,rv1,rv2, connectTo);
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
	


		nodeID=node2ID; 
		node=node2;
	}
}
MapGenerator.prototype.cleanNodes = function(){
	for(index in this.mapGraph.nodeDictionary){
		var tmpNode = this.mapGraph.nodeDictionary[index];
		if (tmpNode.connections.length==2){
			tmpNode.flag=true;
			var nodeindex1=tmpNode.connections[0];
			var nodeindex2=tmpNode.connections[1];
			var node1=this.mapGraph.nodeDictionary[nodeindex1];
			var node2=this.mapGraph.nodeDictionary[nodeindex2];
			var dot=getDotProduct(	node1.vertex.x-tmpNode.vertex.x,
									node1.vertex.y-tmpNode.vertex.y,
									node2.vertex.x-tmpNode.vertex.x,
									node2.vertex.y-tmpNode.vertex.y);
			if(dot==1){
				/*var weight=tmpNode.connectionWeights[0] + tmpNode.connectionWeights[1] ; //this may be changed if they are fractions
				node1.push(nodeindex2,weight);
				node2.push(nodeindex1,weight);
				console.log(node1.connections.indexOf(index));
				node1.connections.splice(node1.connections.indexOf(index),1);
				node2.connections.splice(node2.connections.indexOf(index),1);
				delete this.mapGraph.nodeDictionary[index];*/
			}
		}
	}
}