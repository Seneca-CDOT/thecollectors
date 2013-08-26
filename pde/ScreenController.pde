void newMap(){
	removeScreen("Campaign Level");
    if(currentLevel<=5){
    	addScreen("Campaign Level",new CampaignMap(screenWidth*2,screenHeight*2));
    	setActiveScreen("Campaign Level");
    	$("#fuelElement2")
    }
    else{} //call some end of difficulty screen
}
