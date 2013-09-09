/*
	Generates a new map. This does not increment the current level.
*/
void newMap(){
    console.log("==========================================");
    levelCash=0;
	removeScreen("Campaign Level");
    addScreen("Campaign Level",new CampaignMap(screenWidth*2,screenHeight*2));
    setActiveScreen("Campaign Level");
    resetHUD();
}
/*
    Increment the current level and creates a new map.
*/
void nextMap(){
    if(currentLevel<5){
        currentLevel++;
        campaignCash+=levelCash;
        newMap();
    }
    else{
        //end of campaign logic here
        alert("End of difficulty");
    }
}
/*
	Reset the fuel needle to its original position, and the fuel text to its original colour.
*/
void resetHUD(){
	$("#fuelElement2").css("color","white");
	$("#fuelNeedle").css("transform","rotate(0deg)");
}
/*
    Returns a map to its original state, returns the player to the start point,
    and resets game level values
*/
void resetMap(){
    player.layer.resetMap();
    resetHUD();
}
