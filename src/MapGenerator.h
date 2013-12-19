function MapGenerator(numStructs, difficulty){ 	//returns a map object
	var mapGraph= new Graph();
	var structureList= {};
}

findStructure(nodeFrom,nodeIn, fuelAmt){}		//given a node ID, returns true if there is a structure reachable 
												//with the given fuel amount, false otherwise.
findFuel(nodeFrom,nodeIn, fuelAmt){}			//returns an array of nodes where the player would have run out of fuel


/*		Internal Functions (do not use!)		*/

generateMapGraph(){}
generateRawGraph(){}
mapIntersections(){}							//creates nodes and connections based on intersection points
cleanGraph(){}									//removes colinear and overlapping nodes
colinearRemove(){}
validateMap(){}
minConnection(nodeFrom, nodeIn, hops){}
generateStructures(){}
getStructureFromList(nodeID){}				//returns the structure at the specfied node ID
												//possibly make this accessible elsewhere if it is needed
placeFuelStation(noeID){}							//uses findStructure and findFuel to determine if a fuel station
												//should be placed at the specfied node
randomStructureType(_loops){}					//returns a structure type based on the number of loops specified
													