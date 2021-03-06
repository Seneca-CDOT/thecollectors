function MapGenerator(numStructs, difficulty){
	this.mapGraph=new Graph();
	this.structureList=[];
	this.numStructs=numStructs;
	//Based on the difficulty, fill the pool with possible denominators
	var pool=DenominatorPool.easy;
	if(difficulty == 2 || difficulty == 3){
		pool=pool.concat(DenominatorPool.normal);
		if(difficulty == 3)
			pool=pool.concat(DenominatorPool.hard);	
	}
	this.fuel=pool[rng(0,pool.length-1)];
	//Width and height scale based on the level number
	this.maxWidth = screenSizeX * (1+deliveriesToLevel(numStructs)/10);
	this.maxHeight = screenSizeY * (1+deliveriesToLevel(numStructs)/5);
	this.generateMapGraph();
	//console.log(this.mapGraph);
}
/*
	All steps necessary to generate a map.
*/
MapGenerator.prototype.generateMapGraph = function() {
	this.mapGraph.clearGraph();
	this.index=0;
	this.generateRawGraph();
	this.mapIntersections();
	this.validateMap();
	if(!this.startPoint)
		this.generateStructures();
}
/*	
	internal function which should only be called by generateMapGraph()
	Will generate a raw Graph object
	The Graph generated by this function has incomplete and improper connections	
*/
MapGenerator.prototype.generateRawGraph = function(){
	var node=new Node(this.index++,rng(leftPadding,screenSizeX/5),rng(topPadding,screenSizeY/5));
	var nodeID=this.mapGraph.addNode(node);
	var roadCap=this.numStructs*roadsPerStructure; 				//maximum number of roads to generate
	var prevHeading=0;

	//distanceCap is the # of different road distances possible
	var distanceCap=Math.floor(this.fuel / 2);
	for(var i=1; i<=roadCap;i++){	
		var x,y;
		var distance=rng(1,distanceCap);
		distance=baseRoadLength*distance;

		//generate a heading that isn't in the same direction or opposite direction of the previous heading
		if(prevHeading==1)
			var heading=rng(5,8);
		else if(prevHeading==2)
			var heading=rng(1,4);
		else
			var heading=rng(1,8);
		if(heading<5) prevHeading=1;
		else prevHeading=2;
		var success = false;
		var loops = 0;
		while(!success){
			//reduce the distance every 2 loops.
			//this occurs when a road is too long to go in either direction
			if(loops>2 && loops%2==0){
				distance-=baseRoadLength;
			}
			switch(heading){
				case 1:
				case 2:
					x=node.vertex.x;
					y=node.vertex.y-distance;
					if(y<topPadding)
						heading=3;
					else{	
						success = true;
						break;
					}
				case 3:
				case 4:
					x=node.vertex.x;
					y=node.vertex.y+distance;
					if(y>this.maxHeight)
						heading=0;
					else{	
						success = true;
						break;
					}
				case 5:
				case 6:
					x=node.vertex.x-distance;
					y=node.vertex.y;
					if(x<leftPadding){
						heading=7;
					}
					else{
						success = true;
						break;
					}
				case 7:
				case 8:
					x=node.vertex.x+distance;
					y=node.vertex.y;
					if(x>this.maxWidth){
						heading=5;
					}
					else{ success = true; break; }
			}
			loops++;
		}
		//creates a new Node based on the generated distance and heading
		var node2=new Node(this.index++,x,y);
		var node2ID=this.mapGraph.addNode(node2);

		//conenct the new node to the previous node
		this.mapGraph.addConnection(node2ID,nodeID);
		nodeID=node2ID; 
		node=node2;
	}
}
/*	
	Internal function to be called only by generateMapGraph()
	Takes the Graph generated by generateRawGraph() and maps it's intersection points
*/
MapGenerator.prototype.mapIntersections = function(){
	var nodes=this.mapGraph.nodeDictionary;
	var edges=this.mapGraph.getEdgeList();
	var tmpGraph= new Graph();
	var j=0;
	//find intersection points and create connections to reflect these intersections
	for(var index in edges){
		var node1=nodes[index];
		for (var i = edges[index].length - 1; i >= 0; i--) {
			var node2=nodes[edges[index][i]];
			//Check if the line represented by node1 and node2 intersects with another line
			var intersectCheck=this.mapGraph.edgeIntersects(node1.vertex.x,node1.vertex.y,node2.vertex.x,node2.vertex.y)
			if(intersectCheck){			
				var node1ID=new Node(j, node1.vertex.x, node1.vertex.y);
				node1ID=tmpGraph.addNode(node1ID);
				if(node1ID==j)j++;
				var node2ID=new Node(j, node2.vertex.x, node2.vertex.y);
				node2ID=tmpGraph.addNode(node2ID); if(node2ID==j)j++;
				//Create new nodes at each point of intersection 
				for (var i = intersectCheck.length - 1; i >= 0; i--) {
					if(!intersectCheck[i].colinear){
						var intNode=new Node(j, intersectCheck[i].x, intersectCheck[i].y);
						intNode=tmpGraph.addNode(intNode); if(intNode==j)j++;
						var node3=new Node(j, intersectCheck[i].x1, intersectCheck[i].y1);
						node3=tmpGraph.addNode(node3); if(node3==j)j++;
						var node4=new Node(j, intersectCheck[i].x2, intersectCheck[i].y2);
						node4=tmpGraph.addNode(node4); if(node4==j)j++;
						var tmpNodes=tmpGraph.nodeDictionary;
						tmpGraph.addConnection(intNode,node1ID, 
							new Fraction(distance(tmpNodes[intNode].vertex,tmpNodes[node1ID].vertex)/baseRoadLength,this.fuel));
						tmpGraph.addConnection(intNode,node2ID,
							new Fraction(distance(tmpNodes[intNode].vertex,tmpNodes[node2ID].vertex)/baseRoadLength,this.fuel));
						tmpGraph.addConnection(intNode,node3,
							new Fraction(distance(tmpNodes[intNode].vertex,tmpNodes[node3].vertex)/baseRoadLength,this.fuel));
						tmpGraph.addConnection(intNode,node4,
							new Fraction(distance(tmpNodes[intNode].vertex,tmpNodes[node4].vertex)/baseRoadLength,this.fuel));
					}
				}
			}
		}
	}
	//Extensive testing showed this needed to be done 3 times
	this.cleanGraph(tmpGraph);
	this.cleanGraph(tmpGraph);
	this.cleanGraph(tmpGraph);

	
	this.fixOverlappingLines(tmpGraph);
	this.mapGraph=tmpGraph;
}
/*
	An entire function just to fix one bug regarding line overlap.
	How sad :(
*/
MapGenerator.prototype.fixOverlappingLines=function(tmpGraph){
	var nodes=tmpGraph.nodeDictionary;
	var edges=tmpGraph.getEdgeList();
	for(var index in edges){
		var node1=nodes[index];
		for (var i = edges[index].length - 1; i >= 0; i--) {
			var node2=nodes[edges[index][i]];
			var intersectCheck=tmpGraph.edgeIntersects(node1.vertex.x,node1.vertex.y,node2.vertex.x,node2.vertex.y);
			for (var i = intersectCheck.length - 1; i >= 0; i--) {
				if(intersectCheck[i].colinear){
					var node3 = tmpGraph.vertexExists(new Vertex(intersectCheck[i].x1,intersectCheck[i].y1));
					var node4 = tmpGraph.vertexExists(new Vertex(intersectCheck[i].x2,intersectCheck[i].y2));
					//check if these lines are overlapping, and do not share a node point
					if(node3 != node1.id && node3 != node2.id && node4 != node1.id && node4 != node2.id){
						node3 = nodes[node3];
						node4 = nodes[node4];
						var min,min2,max,max2;
						tmpGraph.removeConnection(node1.id,node2.id);
						tmpGraph.removeConnection(node3.id,node4.id);
						//lines are on the x-plane
						if(node1.vertex.x == node2.vertex.x){
							if(node1.vertex.y < node2.vertex.y){
								min = node1;
								max = node2;
							}
							else{
								min = node2;
								max = node1;
							}
							if(node3.vertex.y < node4.vertex.y){
								min2 = node3;
								max2 = node4;
							}
							else{
								min2 = node4;
								max2 = node3;
							}
						}
						//lines are on the y-plane
						else if(node1.vertex.y == node2.vertex.y){
							if(node1.vertex.x < node2.vertex.x){
								min = node1;
								max = node2;
							}
							else{
								min = node2;
								max = node1;
							}
							if(node3.vertex.x < node4.vertex.x){
								min2 = node3;
								max2 = node4;
							}
							else{
								min2 = node4;
								max2 = node3;
							}
						}
						//fix connections using overlapRemove(). Change the order of the arguments based on the situation
						if(min2 < min && max2 > max) this.overlapRemove(min2,min,max,max2,tmpGraph);
						else if(min2 < min && max2 < max) this.overlapRemove(min2,min,max2,max,tmpGraph);
						else if(min2 > min && max2 < max) this.overlapRemove(min,min2,max2,max,tmpGraph);
						else if(min2 > min && max2 > max) this.overlapRemove(min, min2, max, max2, tmpGraph);
						
					}
				}
			}
		}
	}
}
/*
	Used by fixOverlappingLines to fix connections of overlapping lines
	The order of the nodes is important, and mirrors the order they appear in 2d space
*/
MapGenerator.prototype.overlapRemove = function(min, rmvNode1, rmvNode2, max, tmpGraph){
	if(rmvNode1.connectionsLength==0 && rmvNode2.connectionsLength==0) 
		tmpGraph.addConnection(min.id, max.id, new Fraction(distance(min.vertex, max.vertex)/baseRoadLength,this.fuel));
	else if(rmvNode1.connectionsLength>0 && rmvNode2.connectionsLength>0){
		tmpGraph.addConnection(min.id, rmvNode1.id, new Fraction(distance(min.vertex, rmvNode1.vertex)/baseRoadLength,this.fuel));
		tmpGraph.addConnection(rmvNode1.id, rmvNode2.id, new Fraction(distance(rmvNode1.vertex, rmvNode2.vertex)/baseRoadLength,this.fuel));
		tmpGraph.addConnection(rmvNode2.id, max.id, new Fraction(distance(rmvNode2.vertex, max.vertex)/baseRoadLength,this.fuel));
	}
	else if(rmvNode1.connectionsLength>0){
		tmpGraph.addConnection(min.id, rmvNode1.id, new Fraction(distance(min.vertex, rmvNode1.vertex)/baseRoadLength,this.fuel));
		tmpGraph.addConnection(rmvNode1.id, max.id, new Fraction(distance(rmvNode1.vertex, max.vertex)/baseRoadLength,this.fuel));
	}
	else if(rmvNode2.connectionsLength>0){
		tmpGraph.addConnection(min.id, rmvNode2.id, new Fraction(distance(min.vertex, rmvNode2.vertex)/baseRoadLength,this.fuel));
		tmpGraph.addConnection(rmvNode2.id, max.id, new Fraction(distance(rmvNode2.vertex, max.vertex)/baseRoadLength,this.fuel));
	}
}
/*
	Searches for colinear and overlapping connections and fixes them.
	Searches for nodes between 2 other nodes (colinearly) and removes them.
*/
MapGenerator.prototype.cleanGraph = function(tmpGraph){
//necessary to remove extraneous nodes that persisted due to colinear lines
	nodes=tmpGraph.nodeDictionary;
	for(var index in nodes){
		var node1=nodes[index];
		for(var indx in node1.connections){
			var node2=nodes[indx];
			for(var indekkusu in node1.connections){
				if(indx != indekkusu){
					var node3=nodes[indekkusu];
					this.colinearRemove(tmpGraph,node1,node2,node3);
				}
			}
		}
	}
	// Looks for nodes between 2 other nodes
	// Maybe this belongs in colinearRemove as the else{} 
	for(var index in nodes){
		var node1=nodes[index];
		var node2=null, node3=null;
		if(node1.connectionsLength==2){
			for(var indx in node1.connections){
				if(indx != index && !node2){
					node2=nodes[indx];
				}
				else if(indx != index && indx != node2.id){
					node3=nodes[indx];
				}
			}
			var intersectCheck=segIntersection(node1.vertex.x, node1.vertex.y,
														node2.vertex.x, node2.vertex.y,
														node1.vertex.x, node1.vertex.y,
														node3.vertex.x, node3.vertex.y);
			if(intersectCheck.colinear){
				if(node1.vertex.extendedSlope(node2.vertex) != node1.vertex.extendedSlope(node3.vertex)){
					//remove the middle node and connect the other two nodes
					tmpGraph.removeConnection(node1.id,node2.id);
					//console.log("removed connection between "+node1.id+" and "+node2.id);
					tmpGraph.removeConnection(node1.id,node3.id);
					//console.log("removed connection between "+node1.id+" and "+node3.id);

					tmpGraph.addConnection(node2.id, node3.id,
						new Fraction(distance(node2.vertex, node3.vertex)/baseRoadLength,this.fuel));
					tmpGraph.removeNode(node1.id);
					//check for overlapping colinear connections after the middle point has been removed
					//not even sure if this is necessary anymore :S
					for(var id in node2.connections){
						if(id!=node3.id){
							var node4 = nodes[id];
							this.colinearRemove(tmpGraph,node2,node3,node4);
						}
					}
					for(var id in node3.connections){
						if(id!=node2.id){
							var node4 = nodes[id];
							this.colinearRemove(tmpGraph,node2,node3,node4);
						}
					}
				}
			}

		}
	}
}
/*
	Given 3 nodes, tests if they are colinear.
	If they are colinear and overlapping, modify the connections.
*/
MapGenerator.prototype.colinearRemove = function(_graph,node1,node2,node3){
	var intersectCheck=segIntersection(node1.vertex.x, node1.vertex.y,
										node2.vertex.x, node2.vertex.y,
										node1.vertex.x, node1.vertex.y,
										node3.vertex.x, node3.vertex.y);
	//colinear lines found that connect to the same node
	if(intersectCheck && intersectCheck.colinear){
		//if both lines have the same "direction", remove the connection with the farther node
		if(node1.vertex.extendedSlope(node2.vertex) == node1.vertex.extendedSlope(node3.vertex)){
			var dist1=distance(node1.vertex,node2.vertex);
			var dist2=distance(node1.vertex,node3.vertex);
			if(dist1<dist2){
				_graph.removeConnection(node1.id, node3.id);
				//console.log("removed connection between "+node1.id+" and "+node3.id);
				if(node1.connectionsLength==0) _graph.removeNode(node1.id);
				_graph.addConnection(node2.id, node3.id,
					new Fraction(distance(node2.vertex, node3.vertex)/baseRoadLength,this.fuel));
			}
		}
	}
}
/*
	Tests whether the map is valid or not.
	Requires a minimum number of roads. Requires minConnections() on each node to be true.
	Makes sure no road has a length greater than half the fuel tank.
*/
MapGenerator.prototype.validateMap = function(){
	var invalid = false;
	//remove any nodes without connections left over
	for(var index in this.mapGraph.nodeDictionary){
		if(this.mapGraph.nodeDictionary[index].connectionsLength==0)
			this.mapGraph.removeNode(index);
	}
	//if there are too few nodes after removal, generate a new map
	if(this.mapGraph.length < this.numStructs * (roadsPerStructure-1))
		invalid = true;
	//run minConnections() on each Node to see if a one-direction path has been generated
	//if minConnections() is not satisfied, generate a new map
	if(!invalid){
		for(var index in this.mapGraph.nodeDictionary){
			if(!this.minConnections(-1,index,0)){
				invalid=true;
				break;
			} 
			//check if the node has a connection with a weight greater than half the fuel tank
			var node = this.mapGraph.nodeDictionary[index];
			for(var idx in node.connections){
				if(node.connections[idx].numerator > this.fuel/2){

					invalid=true;
					break;
				}
			}
		}
	}
	if(invalid) this.generateMapGraph();
}
/*
	Recursive Algorithim to test if a node or one of its nearby connected
	nodes has at least 3 connections, a.k.a not making a one direction path.
	Currently tests a chain of up to 3 nodes
*/
MapGenerator.prototype.minConnections = function(nodeFrom, nodeIn, hops){
	var node=this.mapGraph.nodeDictionary[nodeIn];
	if(node.connectionsLength <= 2){
		if(hops == 3)
			return false;
		else{
			for(var index in node.connections){
				if(index!=nodeFrom){
					var rv=this.minConnections(nodeIn,index,hops+1);
					if(!rv) return false;
				}
			}
			return true;
		}
	}
	else return true;
}
/*
	Generates structures...
*/
MapGenerator.prototype.generateStructures = function(){
	var nodes = this.mapGraph.nodeDictionary;
	var structCount=0;
	if(numStructureTypes%structsPerPoints == 0)
		var hopSize=2;
	else
		var hopSize=3;
	hopSize=hopSize*structsPerPoints;
	//	generates structures at dead-ends
	for(var index in nodes){
		if(nodes[index].connectionsLength==1 && !this.findStructure(-1,index,this.fuel)){
			this.structureList.push(new Structure(index,
				this.randomStructureType(hopSize*structCount%numStructureTypes)));
			structCount++;
		}
	}
	//	Every loop reduces the fuel amount passed into findStructure
	//	This makes it easier to return false, and then generate a structure
	var loops = 0;
	while(structCount != this.numStructs){
		for(var index in nodes){	
			if(!this.findStructure(-1,index, this.fuel-loops)){
				this.structureList.push(new Structure(index,
					this.randomStructureType(hopSize*structCount%numStructureTypes)));
				structCount++;
				if(structCount == this.numStructs) break;
			}
		}
		loops++;
	}
	var fuelCount = 0;
	for(var i = 0; fuelCount < this.numStructs; i++){
		var fuelDist = fuelToStructMin(this.fuel) - i;
		if(fuelDist <= 1){
			for (var i = this.structureList.length - 1; i >= 0 && fuelCount<this.numStructs; i--) {
				if(this.structureList[i].StructType != "fuel_stn"){
					var structNode = nodes[this.structureList[i].nodeID];
					var possNodes = [];
					for(var index in structNode.connections){
						var connectedStruct = this.getStructureFromList(index);
						if(connectedStruct && connectedStruct.StructType == "fuel_stn")
						{	possNodes = null; break;	}
						if(!connectedStruct)
							possNodes.push(index);
					}
					if(possNodes){
						var greatestNodes = [];
						for (var i = possNodes.length - 1; i >= 0; i--) {
							if(!greatestNodes.length) greatestNodes.push(possNodes[i]);
							else if(structNode.connections[possNodes[i]] > greatestNodes[0]){
								greatestNodes = [];
								greatestNodes.push(possNodes[i]);
							}
							else if(structNode.connections[possNodes[i]] == greatestNodes[0])
								greatestNodes.push(possNodes[i]);
						}
						var nodeToPush=0;
						if(greatestNodes.length>1){
							nodeToPush = rng(0,greatestNodes.length-1);
						}
						this.structureList.push(new Structure(greatestNodes[nodeToPush],"fuel_stn"));
						fuelCount++;
					}
				}
			}
		}
		else{
			for(var index in nodes){
				if(this.placeFuelStation(index, fuelDist)){
					fuelCount++;
				}
			}
		}
	}
	//	Randomizing a start point for the player
	//	Want to make sure the start point isn't on or too close to a structure
	//	loops variable protects against looping too many times/infinite loops
	loops=0;
	do{
		this.startPoint = this.mapGraph.randomNode();
		loops++;
	}
	while(this.getStructureFromList(this.startPoint.id) && this.findStructure(-1,this.startPoint.id,this.fuel-loops/2));

	this.startPoint = this.startPoint.vertex;
}
/*
	Recursive check for a nearby structure that can be reached with
	the fuel specified by fuelAmt
*/
MapGenerator.prototype.findStructure = function(nodeFrom, nodeIn, fuelAmt,genFuelFlag){
	var node=this.mapGraph.nodeDictionary[nodeIn];
	if(nodeFrom==-1 && !genFuelFlag){
		for(var index in node.connections){
			var tmpStruct = this.getStructureFromList(index);
			if(tmpStruct && tmpStruct.StructType != "fuel_stn")
				return true;
		}
	}
	if(fuelAmt <= 0)
		return false;
	var structureAtNode = this.getStructureFromList(nodeIn);
	if(structureAtNode && structureAtNode.StructType != "fuel_stn")
		return true;
	for(var index in node.connections){
		if(index!=nodeFrom){
			var rv=this.findStructure(nodeIn,index,fuelAmt-node.connections[index].numerator);
			if(rv!=false) return rv;
		}
	}
	return false;
}
MapGenerator.prototype.findFuel = function(nodeFrom,nodeIn, fuelAmt){
	if(fuelAmt <= 0)
		return nodeIn;
	var structureAtNode = this.getStructureFromList(nodeIn);
	if(structureAtNode && structureAtNode.StructType == "fuel_stn")
		return true;

	var node=this.mapGraph.nodeDictionary[nodeIn];
	var nodeArray = [];
	for(var index in node.connections){
		if(index!=nodeFrom){
			var rv=this.findFuel(nodeIn,index,fuelAmt-node.connections[index].numerator);
			if(rv){
				if(getType(rv) == "Array"){
					nodeArray = nodeArray.concat(rv);
				}
				else if(rv !== true)
					nodeArray.push(rv);
				else return rv;
			}
		}
	}
	return nodeArray;
}
//this can be restructured to be more efficient
MapGenerator.prototype.placeFuelStation = function(nodeID, fuelDist){
	var rv = this.findStructure(-1,nodeID,fuelDist,true);
	var rv2 = this.findFuel(-1,nodeID,fuelDist);
	var structureAtNode = this.getStructureFromList(nodeID);
	if(structureAtNode)
		return false;
	if(!rv && rv2!==true){
		if(!this.getStructureFromList(nodeID)){
			this.structureList.push(new Structure(nodeID,"fuel_stn"));
			return true;
		}
	}
	return false;
}
/*
	Returns the structure in structureList at the specified node ID
*/
MapGenerator.prototype.getStructureFromList = function(nodeID) {
	for (var i = this.structureList.length - 1; i >= 0; i--) {
		if(this.structureList[i].nodeID == nodeID)
			return this.structureList[i];
	}
	return false;
}
/*
	Returns a structure type to use for generation
*/
MapGenerator.prototype.randomStructureType = function(_loops){
	var loops = 0;
	var returnNext = 0;
	for(var index in StructureValues){
		if(returnNext){
			if(returnNext==1)
				return index;
			else
				returnNext--;
		}
		if(loops == _loops){
			var rand = rng(1,structsPerPoints);
			if(rand==1) return index;
			else returnNext = structsPerPoints-1;
		}
		loops++;
	}
}
