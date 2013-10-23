/*
	Generates a new map. This does not increment the current level.
*/
void newMap(){
    levelCash=0;
    if(getScreen("Campaign Level"))
	   removeScreen("Campaign Level");
    addScreen("Campaign Level",new CampaignMap(screenWidth*2,screenHeight*2));
    setActiveScreen("Campaign Level");
    resetHUD();
    $(".interHUD").hide();
    $(".HUD").show();
}
/*
    Intermediate screen for campaign
*/
void interMap(){
    $(".HUD").hide();
    $("#campaignCashText").text("$"+campaignCash);
    $(".interHUD").show();
    if(!getScreen("Inter Screen"))
        addScreen("Inter Screen",new InterScreen(screenWidth,screenHeight));
    setActiveScreen("Inter Screen");
}
/*
    Increment the current level and creates a new map.
*/
void nextMap(){
    if(currentLevel<5){
        currentLevel++;
        campaignCash+=levelCash;
        interMap();
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
    if(showFractionBox){
        backToMap();
    }
}
/*
    Returns a map to its original state, returns the player to the start point,
    and resets game level values
*/
void resetMap(){
    player.layer.resetMap();
    resetHUD();
}
