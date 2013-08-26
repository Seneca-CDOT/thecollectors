void newMap(){
	removeScreen("Campaign Level");
    if(currentLevel<=5){
    	addScreen("Campaign Level",new CampaignMap(screenWidth*2,screenHeight*2));
    	setActiveScreen("Campaign Level");
    	resetFuelGuage();
    }
    else{} //call some end of difficulty screen
}
void resetFuelGuage(){
	$("#fuelElement2").css("color","white");
	$("#fuelNeedleDiv").css("transform","rotate(0deg)");
}
