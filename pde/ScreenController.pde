/*
	Generates a new map. This does not increment the current level.
*/
void newMap(){
	removeScreen("Campaign Level");
    addScreen("Campaign Level",new CampaignMap(screenWidth*2,screenHeight*2));
    setActiveScreen("Campaign Level");
    levelCash=0;
    resetHUD();
}
void nextMap(){
    if(currentLevel<5){
        currentLevel++;
        campaignCash+=levelCash;
        newMap();
    }
    else{
        alert("End of difficulty");
    }
}
/*
	Reset the fuel needle to its original position, and the fuel text to its original colour.
*/
void resetHUD(){

	$("#fuelElement2").css("color","white");
	$("#fuelNeedle").css("transform","rotate(0deg)");
    $("#cashElement").html("$" + levelCash);
}
