/**
 *  Handles initialization of game variables and processing instance.
 */

final int screenWidth=screenSizeX;
final int screenHeight=screenSizeY;

PGraphics shadowMap = null;
var shadowMapColorDictionary;
var roadSelectedDictionary;
var futurePosition;
float VEHICLE_SPEED = 1.5;
var NEEDLE_RANGE = 90; // degrees
var BONUS_CASH_AMT = 500;
float zoomLevel = 1.0;
int arrowSpeed=10;

//tracking game values
int gameDifficulty = 1;
int currentLevel = 1;
int levelCash = 0;
int campaignCash = 0;
int deliveriesLeft = 0;
var mapScreen = false;
var gameOver = false;
var refueled = false;
var driveFlag;
var carInventory = [1] , currentVehicle = 1;

//line width
strokeWeight(4);

/*debugging tools*/
boolean debugging=true;
var showMenus=true;

var DISPLAY_SHADOWMAP = false;
var mouseOffsetX = 0;
var mouseOffsetY = 0;

bindCanvasOverlay();

boolean getMousePressed(){
    return mousePressed;
}
void changeMousePressed(boolean _in){
    mousePressed = _in;
}
void changeMousePressed(boolean _in, String buttonPressed){
    switch(buttonPressed){
        case "LEFT":
            mouseButton = LEFT;
            break;
        case "CENTER":
            mouseButton = CENTER;
            break;
        case "RIGHT":
            mouseButton = RIGHT;
            break;
    }
    mousePressed = _in;
}
void mouseOver() {
    if(stopDragging) mousePressed = false;
    canvasHasFocus = true;
}

void mouseOut() {
    stopDragging = true;
    canvasHasFocus = false;
}
void startTutorial() {
    GEN_TUTORIAL = true;
    tutorialIndex = 0;
    instructionIndex = 0;
    document.getElementById("tutorialTextElement").innerHTML = tutorialText[tutorialIndex];
    document.getElementById("instructionTextElement").innerHTML = instructionText[instructionIndex];
    startCampaign(1);
}
void startCampaign(int diff){
    gameDifficulty = diff;
    currentLevel = 1;
    campaignCash = 0;
    carInventory = [1];
    currentVehicle = 1;
    sketch.newMap();
    $("#mainMenuWrap").hide();
}
void startQuickplay(int diff, int size){
    gameDifficulty = diff;
    currentLevel = size;
    campaignCash = 0;
    carInventory = [1];
    currentVehicle = 1;
    sketch.newMap();
    $("#mainMenuWrap").hide();
}
void initialize() {
    sketch = Processing.instances[0];
    clearScreens(); // reset the screen
    if(showMenus){
        initMainMenu();
    }
    else{
        addScreen("Campaign Level",new CampaignMap(screenWidth*2,screenHeight*2));
        setActiveScreen("Campaign Level");
        addScreen("Inter Screen",new InterScreen(screenWidth,screenHeight));
    }
}
