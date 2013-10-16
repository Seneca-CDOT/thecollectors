//	Environment Values 	//
var sketch, player;
var screenSizeX=940;
var screenSizeY=600;

//	Assets Folder		//
var assetsFolder = "assets/";
var structureFolder	= "assets/buildings_png/";
var vehicleFolder	= "assets/vehicles_png/";

//	Static Game Values 	//
var StructureValues={
	airport:1100,
	powerplant:1100,
	hospital:1000,
	train_stn:1000,
	barn:900,
	art_gallery:900,
	cafe:850,
	restaurant:850,
	house:750,
	bakery:750,
	fuel_stn:1000			//refers to the COST of one full tank of fuel on Hard difficulty
};
var StructureCaptions={
	airport:"Airport",
	powerplant:"Power Plant",
	hospital:"Hospital",
	train_stn:"Train Station",
	barn:"Farm",
	art_gallery:"Art Gallery",
	cafe:"Cafe",
	restaurant:"Restaurant",
	house:"House",
	bakery:"Bakery",
	fuel_stn:"Fuel Station"
};
var fuelCost={			//I think 60% fuel cost for easy may be TOO easy. To be tweaked
	easy: 0.6,
	normal: 0.8,
	hard: 1
};
var DenominatorPool={	//denominations subject to change (read : likely)
	easy: [6,8,10],
	normal: [9,12,16],
	hard: [7,15,14]
};
var clearMultipliers={
	easy: 1,
	normal: 2,
	hard: 4
};
var answerBonus={
						//dont really know about this one yet
};
var vehicleTypes={
	1:["bike_top.png","bike_top_long.png"],
	2:["car_top.png","car_top_long.png"],
	3:["suv_top.png","suv_top_long.png"],
	4:["mini_top.png","mini_top_long.png"],
	5:["convert_top.png","convert_top_long.png"]
};
var vehicleCosts={
	1:1000,
	2:2000,
	3:3000,
	4:4000,
	5:5000
};
//	Map Generator Values //
var roadsPerStructure = 4;
var baseRoadLength = 100;
var	numStructureTypes = 10;
var structsPerPoints = 2;		//refers to the number of structures with equivalent point values

function fuelToStructMin(fuel){return Math.round(fuel/4);}
function fuelToFuelMin(fuel){return Math.ceil(fuel/4);}

var topPadding = 50;
var botPadding = 50;
var leftPadding = 50;
var rightPadding = 350;		//extra 300px to accomadate the fuel guage width

function levelToDeliveries(currLevel){
	return 2*currLevel+2;
}
function deliveriesToLevel(deliveries){
	return (deliveries-2)/2;
}
