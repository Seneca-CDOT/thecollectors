/*
	Generates a new map. This does not increment the current level.
*/
void newMap(){
	removeScreen("Campaign Level");
    if(currentLevel<=5){
    	addScreen("Campaign Level",new CampaignMap(screenWidth*2,screenHeight*2));
    	setActiveScreen("Campaign Level");
    	resetFuelGuage();
    }
    else{} //call some end of difficulty screen
}
/*
	Reset the fuel needle to its original position, and the fuel text to its original colour.
*/
void resetFuelGuage(){
	$("#fuelElement2").css("color","white");
	$("#fuelNeedle").css("transform","rotate(0deg)");
}
