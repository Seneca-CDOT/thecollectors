function Map(numStructs, difficulty, filename){
	mapGraph										//Graph object
	structureList 									//Array of javascript structures
	pjsStructureList								//Associative array of processing structures
	fuel											//Fraction representing the fuel gauge
	startPoint										//vertex where the player starts
}
getStructById(){}									//returns the structure with the specified id
getEdgeList(){}										//returns an object that contains all edges in the map
initNodesFromXML(){}								//internally called to parse an XML object to generate the mapGraph
initStructuresFromXML(){}							//internally called to parse an XML object to generate the structureList	
exportToXML(){}										//exports map info as an XML string
