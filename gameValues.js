//	Environment Values 	//
var sketch, player;
var screenSizeX=940;
var screenSizeY=640;

//	Assets Folder		//
var assetsFolder = "assets/";

//	Static Game Values 	//
var StructureValues={
	office:1100,
	restaurant:1100,
	power_plant:1000,
	apartments:1000,
	school:900,
	house:900,
	farm:850,
	factory:850,
	lumber_yard:750,
	cafe:750,
	fuel:1000	//refers to the COST of one full tank of fuel on Hard difficulty
};
var StructureCaptions={
	office:"Office",
	restaurant:"Restaurant",
	power_plant:"Power Plant",
	apartments:"Apartments",
	school:"School",
	house:"House",
	farm:"Farm",
	factory:"Factory",
	lumber_yard:"Lumber Yard",
	cafe:"Cafe",
	fuel:"Fuel Station"
};
var DenominatorPool={	//denominations subject to change (read : likely)
	easy: [6,8,10],			// 6,8,10
	normal: [9,12,14],      // 9,12,14
	hard: [7,15,16]             // 7,15,16
};
var clearMultipliers={
	easy: 1,
	normal: 2,
	hard: 4
};
var answerBonus={
	//dont really know about this one yet
};

//	Map Generator Values //
var roadsPerStructure = 5;
var baseRoadLength = 100;