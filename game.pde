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
boolean debugging=false;
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
    $("#clearButton").prop('disabled', true);
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
/**
 *  Handles setup of campaign maps.
 */

class CampaignMap extends Level {
    var denominator = 0;
    var renderedEndScreen = false;

    CampaignMap(float mWidth, float mHeight) {
        super(mWidth, mHeight);
        setViewBox(0, 0, screenWidth, screenHeight);

        if (GEN_TUTORIAL) {
            generateTutorial();
        } else {
            generateMap();
        }
    }
    // Generate the tutorial map. The map is static except for the denominator, and is
    // imported from an XML file.
    void generateTutorial() {
        var map = null;
        deliveriesLeft = 3;
        map = new Map(0,0,"tutorial.xml");
        renderMap(map);
        overlayTutorialInterface();
    }
    // For the tutorial, we need to enable a custom overlay that shows the player
    // the parts of the game in a certain order and guides them through the gameplay.
    void overlayTutorialInterface() {
        $("#tutorialTextDiv").show();
        $("#legendDiv").show();
    }
    void generateMap() {
        deliveriesLeft = levelToDeliveries(currentLevel);
        var simpleMultiples = true;
        var map=new Map(deliveriesLeft,gameDifficulty);
        width = map.width;
        height = map.height;
        renderMap(map);
    }
    void renderMap(generatedMap) {
        mapScreen = true;
        addLevelLayer("Level", new MapLevel(this, generatedMap));
    }
/*    void draw() {
        super.draw();

        // Check if all deliveries for the level have been satisfied
        if (deliveriesLeft <= 0 && !renderedEndScreen) {
            cleanUp();
            end();
            mapScreen = false;
            setViewBox(0, 0, screenWidth, screenHeight);
            addLevelLayer("Win Screen", new WinScreen(this));
            renderedEndScreen = true;
            campaignCash += levelCash;
            //document.getElementById("fuelDiv").style.cssText = 'display:none';
            //document.getElementById("fuelGaugeDiv").style.cssText = 'display:none';
            //document.getElementById("fuelNeedleDiv").style.cssText = 'display:none';
        } else if (gameOver && !renderedEndScreen) {
            cleanUp();
            end();
            mapScreen = false;
            setViewBox(0, 0, screenWidth, screenHeight);
            addLevelLayer("Game Over Screen", new GameOverScreen(this));
            renderedEndScreen = true;
            roadSelectedDictionary = null;
            //document.getElementById("fuelDiv").style.cssText = 'display:none';
            //document.getElementById("fuelGaugeDiv").style.cssText = 'display:none';
            //document.getElementById("fuelNeedleDiv").style.cssText = 'display:none';
        }
    }
*/
}
/**
 *  Controls the car. Handles user input.
 */

class Driver extends Player{
    var currentPosition, previousPosition, destination, currDest;
    var edgeDelta = 0, roadDeltaX = 0, roadDeltaY = 0, direction = 0;
    var currDestColorID, nodeMap, fuelGauge, fuelCost;
    var destinationWeight, deltaPerTick, tickDelta = 0, previousVehicleDelta = 0;
    var fuelGaugeHUD, fuelNeedleHUD, cashHUD, needlePosition = 0, needleDelta = 0;
    var cashAnimHUD, cashAnimEl, cashAnimEl2;
    Driver(map) {
        super("Driver");
        setStates();
        handleKey('+');
        handleKey('='); // For the =/+ combination key
        handleKey('-');
        handleKey(' ');
        nodeMap = map;
        currentPosition = nodeMap.startPoint.clone();
        futurePosition = currentPosition; // for multi-road selection
        setPosition(currentPosition.x, currentPosition.y);
        previousPosition = new Vertex(getPrevX(), getPrevY());
        destination = [];
        destinationWeight = null;
        currDest = null;
        currDestColorID = [];
        driveFlag = false;
        fractionBox = document.getElementById("fractionBoxDiv");
        fractionImg = document.getElementById("fractionBonusImg");
        fractionText = document.getElementById("fractionTextDiv");
        fractionCT = null;
        cashAnimEl = document.getElementById("cashAnimElement");
        cashAnimEl2 = document.getElementById("cashAnimElement2");
        fuelGauge = new Fraction(nodeMap.fuel.numerator, nodeMap.fuel.denominator);
        fuelGaugeHUD = document.getElementById("fuelElement2");
        fuelGaugeHUD.innerHTML = fuelGauge.numerator.toString();
        fuelGaugeHUD.innerHTML += "<br /><hr />";
        fuelGaugeHUD.innerHTML += fuelGauge.denominator.toString();
        needleDelta = NEEDLE_RANGE / fuelGauge.denominator;
        fuelNeedleHUD = document.getElementById("fuelNeedle");
        cashHUD = document.getElementById("cashElement");
        cashHUD.innerHTML = "$" + levelCash;
        parcelHUD = document.getElementById("parcelElement");
        parcelHUD.innerHTML = "x " + deliveriesLeft;
        var fuelCostWeight = 1.0 - (0.6 - gameDifficulty * 0.2);
        fuelCost = Math.floor(StructureValues.fuel_stn * fuelCostWeight / fuelGauge.denominator);
        bonusTracker.array = [];
        bonusTracker.initialBonusIndex = -1;
    }
    void handleInput(){
        if (canvasHasFocus && mapScreen) {
            if (keyCode){
                ViewBox box=layer.parent.viewbox;
                int _x=0, _y=0;
                if(keyCode==UP){
                    _y-=arrowSpeed;
                }
                if(keyCode==DOWN){
                    _y+=arrowSpeed;
                }
                if(keyCode==LEFT){
                    _x-=arrowSpeed;
                }
                if(keyCode==RIGHT){
                    _x+=arrowSpeed;
                }
                if (keyCode==ENTER) {
                }
                if (keyCode==BACKSPACE) {
                    clearRoute();
                }
                if (keyCode==DELETE) {
                    if (destination.length == 1 ||
                            (destination.length > 0 && bonusTracker.initialBonusIndex == -1)) {
                        driveToDestination();
                    } else {
                        if (destination.length > 0 && !showFractionBox) {
                            $("#fractionBoxDiv").show();
                            $("#fractionBonusImg").show();
                            $("#fractionBackImg").show();
                            $("#fracSumNum").focus();
                            $("#fuelWrap").hide();
                            showFractionBox = true;
                        }
                    }
                }
                box.translate(_x,_y,layer.parent,layer.xScale, layer.yScale);
            }
            if(mouseScroll!=0){
                layer.zoom(mouseScroll/10);
                mouseScroll=0;
            }
            if(isKeyDown('+') || isKeyDown('=')){
                layer.zoom(1/3/10);
            }
            if(isKeyDown('-')){
                layer.zoom(-1/3/10);
            }
            if(isKeyDown(' ')){                     //key is subject to change
                ViewBox box=layer.parent.viewbox;
                box.track(layer.parent,this);
            }
        }
        mouseScroll=0;
        keyCode=undefined;
    }
    void clearRoute() {
        if (GEN_TUTORIAL) return;
        if (!mapScreen) return;
        if (showFractionBox) return;
        if (driveFlag) return;

        bonusTracker.array.length = 0;
        bonusTracker.initialBonusIndex = -1;
        fractionArray.length = 0;
        futurePosition = currentPosition;
        destination.length = 0;
        var len = currDestColorID.length;
        for (var i = 0; i < len; i++) {
            roadSelectedDictionary[currDestColorID[i]][0] = 0;
            roadSelectedDictionary[currDestColorID[i]][1] = 0;
        }
        currDestColorID.length = 0;
        fractionText.innerHTML = "";
    }
    void mouseMoved(int mx, int my){
        canvasHasFocus=true;
    }
    void driveToDestination() {

        var impulseX = 0, impulseY = 0;

        refueled = false;
        fractionArray.length = 0;
        if (bonusTracker.array.length > 0) {
            bonusTracker.array.length = 0;
            bonusTracker.initialBonusIndex = -1;
        }
        // Get the current destination from the destination list
        currDest = destination.shift();
        roadDeltaX = currDest.vertex.x - currentPosition.x;
        roadDeltaY = currDest.vertex.y - currentPosition.y;

        // Set the vehicle direction and speed
        if (roadDeltaX != 0 && !roadDeltaY) {
            if (roadDeltaX > 0) {
                direction = HALF_PI;
                impulseX = VEHICLE_SPEED;
            } else if (roadDeltaX < 0) {
                direction = -HALF_PI;
                impulseX = -VEHICLE_SPEED;
            }
        }
        if (roadDeltaY != 0 && !roadDeltaX) {
            if (roadDeltaY > 0) {
                direction = PI;
                impulseY = VEHICLE_SPEED;
            } else if (roadDeltaY < 0) {
                direction = 0;
                impulseY = -VEHICLE_SPEED;
            }
        }

        setRotation(direction);
        setImpulse(impulseX, impulseY);
        edgeDelta = distance(previousPosition, currDest.vertex);

        // Get the connection weight (fraction) between the start
        // node and the destination node
        var idx = nodeMap.mapGraph.vertexExists(previousPosition);
        var startNode = nodeMap.mapGraph.nodeDictionary[idx];
        destinationWeight = startNode.connections[currDest.id];

        // Calculate the distance that the vehicle travels
        // across the current edge on one "tick" of fuel
        deltaPerTick = edgeDelta / destinationWeight.numerator;

        driveFlag = true;
        if (needlePosition > -NEEDLE_RANGE) {
            animateNeedle(30, -needleDelta, needlePosition);
            needlePosition -= needleDelta;
        }
    }
    boolean structureCheck(currentNodeID) {
        // Get the structure list
        
        var sL = nodeMap.pjsStructureList;
        var s = sL[currentNodeID];
        if(s){
            if (s.structObject.StructType == "fuel_stn") {
                s.structObject.visited = true;
            }
            return true;
        }
        return false;
    }
    // If the current structure is a delivery location, add points,
    // if it is a fuel station reduce cash but increase fuel capacity
    void updateInfo(atStruct){
        if (atStruct.StructType != "fuel_stn" && !atStruct.visited) {
            if (bonusFlag) {
                levelCash += BONUS_CASH_AMT;
                cashAnimEl2.innerHTML = "+$" + BONUS_CASH_AMT + " (Bonus)";
                animateBonus();
            }
            levelCash += atStruct.Points;
            atStruct.visited = true;
            deliveriesLeft--;
            cashHUD.innerHTML = "$" + levelCash;
            parcelHUD.innerHTML = "x " + deliveriesLeft;
            cashAnimEl.innerHTML = "+$" + atStruct.Points;
            $("#cashAnimDiv").show();
            animateCash();
        }
        else if (atStruct.StructType == "fuel_stn" && !refueled) {
            refueled = true;
            var fuelMissing = fuelGauge.denominator - fuelGauge.numerator;
            var totalFuelCost = fuelMissing * fuelCost;
            var enoughCash = (levelCash - totalFuelCost) >= 0 ? true : false;
            var fuelString = 0;
            if (enoughCash) {
                levelCash -= totalFuelCost;
                fuelString = totalFuelCost;
                fuelGauge.numerator += fuelMissing;
                needlePosition += fuelMissing * needleDelta;
            } else {
                var total = 0;
                var ticksToFill = 0;
                var keepFilling = true;
                for (var i = 1; i <= fuelMissing && keepFilling; i++) {
                    total += fuelCost;
                    if (total > levelCash) {
                        keepFilling = false;
                        ticksToFill = i - 1;
                        total = ticksToFill * fuelCost;
                    }
                }
                if (ticksToFill) {
                    levelCash -= total;
                    fuelString = total;
                    fuelGauge.numerator += ticksToFill;
                    needlePosition += ticksToFill * needleDelta;
                }
            }
            if (fuelString > 0) {
                cashHUD.innerHTML = "$" + levelCash;
                var costString = "&nbsp;&#8211;$" + fuelString;
                animateCost(costString);
            }
            var fuelLevel = fuelGauge.evaluate();
            if (fuelLevel <= 0.2) {
                fuelGaugeHUD.style.cssText = "color:red";
            } else if (fuelLevel <= 0.5) {
                fuelGaugeHUD.style.cssText = "color:#ff6600";
            } else {
                fuelGaugeHUD.style.cssText = "color:white";
            }
            fuelGaugeHUD.innerHTML = fuelGauge.numerator.toString();
            fuelGaugeHUD.innerHTML += "<br /><hr />";
            fuelGaugeHUD.innerHTML += fuelGauge.denominator.toString();
            fuelNeedleHUD.style.cssText = "transform:rotate("+ needlePosition +"deg);";
        }
    }
    void drawObject() {
        if(deliveriesLeft <= 0){
            if (!GEN_TUTORIAL) {
                nextMap();
            }
            return;
        }
        currentPosition.x = getX();
        currentPosition.y = getY();
        var vehicleDelta = distance(currentPosition, previousPosition);
        if (!gameOver && vehicleDelta > 0) {
            tickDelta += vehicleDelta - previousVehicleDelta;
        }
        previousVehicleDelta = vehicleDelta;

        /* If the vehicle has travelled a greater distance than the distance from its
         * starting location to its destination, stop the vehicle and re-position it
         * on the destination
         */
        if (edgeDelta > 0 && vehicleDelta > 0 && vehicleDelta > edgeDelta) {
            stopVehicle();

            // De-select the road we finished driving over
            var index, delta;
            if (currDest.vertex.x - previousPosition.x == 0) {
                delta = currDest.vertex.y - previousPosition.y;
                index = delta < 0 ? 1 : 0;
            } else if (currDest.vertex.y - previousPosition.y == 0) {
                delta = currDest.vertex.x - previousPosition.x;
                index = delta < 0 ? 1 : 0;
            }
            roadSelectedDictionary[currDestColorID.shift()][index] -= 1;

            setPosition(currDest.vertex.x, currDest.vertex.y);
            previousPosition.x = currentPosition.x = getX();
            previousPosition.y = currentPosition.y = getY();

            // Reset deltas
            roadDeltaX = 0;
            roadDeltaY = 0;
            tickDelta = previousVehicleDelta = 0;

            consumeFuel();

            // Check if we've driven over a structure
            if(structureCheck(currDest.id)){
                updateInfo(nodeMap.pjsStructureList[currDest.id].structObject);
            }

            checkIfFuelEmpty();

            // Keep driving as long as we haven't run out of destinations
            if (!gameOver && destination.length != 0 && deliveriesLeft > 0) {
                driveToDestination();
            } else {
                driveFlag = false;
                bonusFlag = false;
            }
        }

        if (!gameOver && edgeDelta > 0 && tickDelta >= deltaPerTick) {
            tickDelta = 0;
            if (needlePosition > -NEEDLE_RANGE) {
                animateNeedle(30, -needleDelta, needlePosition);
                needlePosition -= needleDelta;
            }
            consumeFuel();
            checkIfFuelEmpty();
        }
        // Draw the vehicle
        super.drawObject();
    }
    // Subtract the fraction from the fuel gauge and update the HUD
    void consumeFuel() {
        fuelGauge.numerator -= 1;
        var fuelLevel = fuelGauge.evaluate();
        if (fuelLevel <= 0.2) {
            fuelGaugeHUD.style.cssText = "color:red";
        } else if (fuelLevel <= 0.5) {
            fuelGaugeHUD.style.cssText = "color:#ff6600";
        } else {
            fuelGaugeHUD.style.cssText = "color:white";
        }
        fuelGaugeHUD.innerHTML = fuelGauge.numerator.toString();
        fuelGaugeHUD.innerHTML += "<br /><hr />";
        fuelGaugeHUD.innerHTML += fuelGauge.denominator.toString();
    }
    // If we're out of fuel and all deliveries have not been completed,
    // the game is over
    void checkIfFuelEmpty() {
        if (fuelGauge.numerator <= 0) {
            gameOver = true;
            levelCash = 0;
            cashHUD.innerHTML = "$" + levelCash;
            vehicleDelta = 0;
            stopVehicle();
        }
    }
    void mouseReleased(int mx, int my, int button) {
        cursor(ARROW);
    }
    void mouseDragged(int mx, int my, int button) {
        if (mapScreen && button == LEFT) {
            cursor(MOVE);
            ViewBox box = layer.parent.viewbox;
            int _x = 0, _y = 0;
            int deltaX = mx - pmouseX;
            int deltaY = my - pmouseY;
            deltaX = deltaX * zoomLevel;
            deltaY = deltaY * zoomLevel;
            if (deltaX < 0) {
                deltaX = Math.floor(deltaX);
            } else {
                deltaX = Math.ceil(deltaX);
            }
            if (deltaY < 0) {
                deltaY = Math.floor(deltaY);
            } else {
                deltaY = Math.ceil(deltaY);
            }

            if (deltaX > 0) _x -= Math.abs(deltaX);
            else if (deltaX < 0) _x += Math.abs(deltaX);
            if (deltaY < 0) _y += Math.abs(deltaY);
            else if (deltaY > 0) _y -= Math.abs(deltaY);
            box.translate(_x, _y, layer.parent, layer.xScale, layer.yScale);
        }
    }
    void mouseClicked(int mx, int my, int button) {
        if(layer.debug){
            //println("x:"+mx+" || "+"y:"+my);
        }
        if (!mapScreen) return;
        if (driveFlag) return;

        // The mouse co-ordinates must be offset by the position of the ViewBox
        // for scrolling and zooming to work properly
        var layerCoords = layer.mapCoordinateFromScreen(mx, my);
        mx = layerCoords[0];
        my = layerCoords[1];

        // Did we click on the vehicle? If not, check if we clicked on a road
        if (button == LEFT && over(mx,my)) {
            if (destination.length == 1 ||
                    (destination.length > 0 && bonusTracker.initialBonusIndex == -1)) {
                driveToDestination();
            } else {
                if (destination.length > 0 && !showFractionBox) {
                    $("#fractionBoxDiv").show();
                    $("#fractionBonusImg").show();
                    $("#fractionBackImg").show();
                    $("#fracSumNum").focus();
                    $("#fuelWrap").hide();
                    showFractionBox = true;
                }
            }
        } else if (destination.length < 10 || button == RIGHT) {
            // Get the hexadecimal colour code at the clicked point on the shadowMap
            color c = shadowMap.get(mx, my);
            c = hex(c);
            if (DISPLAY_SHADOWMAP) console.log(c);

            /* Clicking the left mouse button on a valid road segment highlights that segment and
             * updates the final destination for the vehicle to travel to. Clicking the right
             * mouse button on a valid road segment removes its highlight and updates the vehicle's
             * final destination to the previous node in the route.
             */
            if (shadowMapColorDictionary[c] != null && button == LEFT) {
                var flippedVertexX = shadowMapColorDictionary[c][0].vertex.x -
                    shadowMapColorDictionary[c][1].vertex.x > 0 ? true : false;
                var flippedVertexY = shadowMapColorDictionary[c][0].vertex.y -
                    shadowMapColorDictionary[c][1].vertex.y > 0 ? true : false;
                var fraction = null;

                if (shadowMapColorDictionary[c][0].vertex.equals(futurePosition)) {
                    destination.push(shadowMapColorDictionary[c][1]);
                    if (!flippedVertexX && !flippedVertexY) {
                        roadSelectedDictionary[c][0] += 1;
                    } else if (flippedVertexX || flippedVertexY) {
                        roadSelectedDictionary[c][1] += 1;
                    }
                    fraction = shadowMapColorDictionary[c][0].connections[destination[destination.length - 1].id];
                    futurePosition = shadowMapColorDictionary[c][1].vertex;
                    var st = nodeMap.pjsStructureList[shadowMapColorDictionary[c][1].id];
                    if (st) {
                        if (st.structObject.StructType != "fuel_stn" && !st.structObject.visited) {
                            bonusTracker.array.push(true);
                            if (bonusTracker.initialBonusIndex == -1) {
                                bonusTracker.initialBonusIndex = bonusTracker.array.length - 1;
                            }
                        } else {
                            bonusTracker.array.push(false);
                        }
                    } else {
                        bonusTracker.array.push(false);
                    }
                    currDestColorID.push(c);

                    if (destination.length > 1) {
                        fractionCT.innerHTML += "<div style=\"float:left;padding-top:29px;\">+</div>" +
                            "<div style=\"margin:1px;float:left;width:45px;\">" +
                            "<div id=\"fraction" + destination.length +
                            "\" style=\"text-align:center;margin:10px;\"></div></div>";

                        var fracElement = document.getElementById("fraction" + destination.length);
                        fracElement.innerHTML = fraction.displayNum != undefined ? fraction.displayNum.toString() :
                            fraction.numerator.toString();
                        fracElement.innerHTML += "<br /><hr />";
                        fracElement.innerHTML += fraction.displayDenom != undefined ?
                            fraction.displayDenom.toString() : fraction.denominator.toString();

                        fractionArray.push(fraction);
                    }
                } else if (shadowMapColorDictionary[c][1].vertex.equals(futurePosition)) {
                    destination.push(shadowMapColorDictionary[c][0]);
                    if (!flippedVertexX && !flippedVertexY) {
                        roadSelectedDictionary[c][1] += 1;
                    } else if (flippedVertexX || flippedVertexY) {
                        roadSelectedDictionary[c][0] += 1;
                    }
                    fraction = shadowMapColorDictionary[c][1].connections[destination[destination.length - 1].id];
                    futurePosition = shadowMapColorDictionary[c][0].vertex;
                    var st = nodeMap.pjsStructureList[shadowMapColorDictionary[c][0].id];
                    if (st) {
                        if (st.structObject.StructType != "fuel_stn" && !st.structObject.visited) {
                            bonusTracker.array.push(true);
                            if (bonusTracker.initialBonusIndex == -1) {
                                bonusTracker.initialBonusIndex = bonusTracker.array.length - 1;
                            }
                        } else {
                            bonusTracker.array.push(false);
                        }
                    } else {
                        bonusTracker.array.push(false);
                    }
                    currDestColorID.push(c);

                    if (destination.length > 1) {
                        fractionCT.innerHTML += "<div style=\"float:left;padding-top:29px;\">+</div>" +
                            "<div style=\"margin:1px;float:left;width:45px;\">" +
                            "<div id=\"fraction" + destination.length +
                            "\" style=\"text-align:center;margin:10px;\"></div></div>";

                        var fracElement = document.getElementById("fraction" + destination.length);
                        fracElement.innerHTML = fraction.displayNum != undefined ? fraction.displayNum.toString() :
                            fraction.numerator.toString();
                        fracElement.innerHTML += "<br /><hr />";
                        fracElement.innerHTML += fraction.displayDenom != undefined ?
                            fraction.displayDenom.toString() : fraction.denominator.toString();

                        fractionArray.push(fraction);
                    }
                }
                if (fraction != null && destination.length == 1) {
                    fractionText.innerHTML = "<div id=\"fractionCT\" class=\"inCanvas\"" +
                        "style=\"position:absolute;width:80%;\"></div><div id=\"submitDiv\"" +
                        "style=\"position:absolute;left:80%;width:20%;\"></div>";
                    fractionCT = document.getElementById("fractionCT");
                    fractionCT.innerHTML = "<div style=\"margin:1px;float:left;width:45px;\">" +
                        "<div id=\"fraction" + destination.length +
                        "\" style=\"text-align:center;margin:10px;\"></div></div>";

                    // Add the div containing the input textboxes to the overlay
                    var submitBox = document.getElementById("submitDiv");
                    submitBox.innerHTML += "<div style=\"margin:1px;float:right;width:70px;\">" +
                        "<div id=\"fractionSubmit\"" +
                        "style=\"width:64px;height:64px;background-color:white;margin:5px;\"" +
                        "onclick=\"checkFractionSum()\" >" +
                        "<img src=\"./assets/items/drive_btn.png\" width=\"64px\" height=\"64px\"/></div></div>" +
                        "<div style=\"margin:1px;float:right;width:45px;\">" +
                        "<div id=\"fractionSum\" style=\"text-align:center;\"></div></div>" +
                        "<div style=\"float:right;padding-top:29px;\">=</div>";

                    var fracElement = document.getElementById("fraction" + destination.length);
                    fracElement.innerHTML = fraction.displayNum != undefined ? fraction.displayNum.toString() :
                        fraction.numerator.toString();
                    fracElement.innerHTML += "<br /><hr />";
                    fracElement.innerHTML += fraction.displayDenom != undefined ?
                        fraction.displayDenom.toString() : fraction.denominator.toString();

                    fractionArray.push(fraction);

                    var fracSum = document.getElementById("fractionSum");
                    fracSum.innerHTML = "<div id=\"fractionNum\" style=\"padding:1px;margin:3px;border-radius:3px;\"><input type=\"text\" id=\"fracSumNum\" name=\"numerator\" autocomplete=\"off\" onblur=\"testInput(this)\"" +
                        "onfocus=\"fracHideTooltip(this)\" style=\"width:23px\" /></div>" +
                        "<hr />" +
                        "<div id=\"fractionDenom\" style=\"margin:3px;border-radius:3px;\"><input type=\"text\" id=\"fracSumDenom\" name=\"denominator\" autocomplete=\"off\" onblur=\"testInput(this)\"" +
                        "onfocus=\"fracHideTooltip(this)\" style=\"width:23px\" /></div>";
                }
            } else if (shadowMapColorDictionary[c] != null && button == RIGHT) {
                var prevDest, index, delta = 0;

                if (destination.length > 1) {
                    prevDest = destination[destination.length - 2].vertex;
                } else if (destination.length == 1) {
                    prevDest = currentPosition;
                } else {
                    return;
                }

                if (futurePosition.x - prevDest.x == 0) {
                    delta = futurePosition.y - prevDest.y;
                    index = delta < 0 ? 1 : 0;
                } else if (futurePosition.y - prevDest.y == 0) {
                    delta = futurePosition.x - prevDest.x;
                    index = delta < 0 ? 1 : 0;
                }

                if (roadSelectedDictionary[c][index] > 0 &&
                        c == currDestColorID[currDestColorID.length - 1]) {

                    roadSelectedDictionary[c][index] -= 1;
                    destination.pop();
                    fractionArray.pop();
                    bonusTracker.array.pop();
                    if (bonusTracker.array.length <= bonusTracker.initialBonusIndex) {
                        bonusTracker.initialBonusIndex = -1;
                    }
                    if (destination.length > 0) {
                        futurePosition = destination[destination.length - 1].vertex;

                        // Remove the div elements containing the fraction and the "+" sign
                        var node = fractionCT.children[fractionCT.childElementCount - 1];
                        node.parentNode.removeChild(node);
                        node = fractionCT.children[fractionCT.childElementCount - 1];
                        node.parentNode.removeChild(node);
                    } else {
                        futurePosition = currentPosition;
                        $("#fuelWrap").show();
                        fractionText.innerHTML = "";
                    }
                    currDestColorID.pop();
                }
            }
        }
    }
    void setStates() {
        setScale(0.6);
        addState(new State("Player", assetsFolder+"vehicles/"+vehicleTypes[currentVehicle][0]));
    }
    void stopVehicle() {
        stop();
        edgeDelta = 0;
    }
}

class TutorialDriver extends Driver {
    TutorialDriver(map) {
        super(map);
    }
    void drawObject() {
        // Tutorial position tests
        if (GEN_TUTORIAL && tutorialIndex == 11 && currentPosition.x == 400 && currentPosition.y == 200) {
            $("#tutorialTextDiv").show();
            $("#instructionTextDiv").hide();
            document.getElementById("instructionTextElement").innerHTML = instructionText[++instructionIndex];
            advanceTutorial();
        } else if (GEN_TUTORIAL && tutorialIndex == 16 && currentPosition.x == 300 && currentPosition.y == 200) {
            $("#tutorialTextDiv").show();
            $("#instructionTextDiv").hide();
            document.getElementById("instructionTextElement").innerHTML = instructionText[++instructionIndex];
            advanceTutorial();
        } else if (GEN_TUTORIAL && tutorialIndex == 27 && currentPosition.x == 300 && currentPosition.y == 400) {
            document.getElementById("tutorialTextElement").innerHTML = tutorialText[++tutorialIndex];
            $("#tutorialTextDiv").show();
            $("#highlightBox").css("left", "40px");
            $("#highlightBox").css("top", "0px");
            $("#highlightBox").css("width", "100px");
            $("#highlightBox").css("height", "36px");
            $("#highlightBox").show();
        } else if (GEN_TUTORIAL && tutorialIndex == 31 && currentPosition.x == 400 && currentPosition.y == 500) {
            $("#tutorialTextDiv").show();
            $("#instructionTextDiv").hide();
            document.getElementById("instructionTextElement").innerHTML = instructionText[++instructionIndex];
            advanceTutorial();
        } else if (GEN_TUTORIAL && tutorialIndex == 35 && currentPosition.x == 400 && currentPosition.y == 800) {
            document.getElementById("tutorialTextElement").innerHTML = tutorialText[++tutorialIndex];
        }

        super.drawObject();
    }
    void handleInput() {
        if (canvasHasFocus && mapScreen) {
            if (keyCode){
                ViewBox box=layer.parent.viewbox;
                int _x=0, _y=0;
                if(keyCode==UP){
                    if (GEN_TUTORIAL && tutorialIndex < 3) {
                        // do nothing
                    } else {
                    _y-=arrowSpeed;
                    }
                }
                if(keyCode==DOWN){
                    if (GEN_TUTORIAL && tutorialIndex < 3) {
                        // do nothing
                    } else {
                    _y+=arrowSpeed;
                    }
                }
                if(keyCode==LEFT){
                    if (GEN_TUTORIAL && tutorialIndex < 3) {
                        // do nothing
                    } else {
                    _x-=arrowSpeed;
                    }
                }
                if(keyCode==RIGHT){
                    if (GEN_TUTORIAL && tutorialIndex < 3) {
                        // do nothing
                    } else {
                    _x+=arrowSpeed;
                    }
                }
                if (keyCode==ENTER) {
                    if (GEN_TUTORIAL && (tutorialIndex == 3 || tutorialIndex == 6 || tutorialIndex == 11 ||
                                tutorialIndex == 16 || tutorialIndex == 22 ||
                                tutorialIndex == 27 || tutorialIndex == 31 || tutorialIndex == 35)) {
                        keyCode = undefined;
                        return;
                    }
                    advanceTutorial();
                }
                if (keyCode==DELETE) {
                    if (destination.length == 1 ||
                            (destination.length > 0 && bonusTracker.initialBonusIndex == -1)) {
                        driveToDestination();
                    } else {
                        if (destination.length > 0 && !showFractionBox) {
                            $("#fractionBoxDiv").show();
                            $("#fractionBonusImg").show();
                            $("#fractionBackImg").show();
                            $("#fracSumNum").focus();
                            $("#fuelWrap").hide();
                            showFractionBox = true;
                        }
                    }
                    // Change opacity of tutorial text div during the bonus overlay
                    if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 2) {
                        document.getElementById("tutorialTextElement").innerHTML = tutorialText[++tutorialIndex];
                        $("#tutorialTextDiv").css("opacity", "1.0");
                        $("#highlightBox").css("left", "100px");
                        $("#highlightBox").css("top", "344px");
                        $("#highlightBox").css("width", "600px");
                        $("#highlightBox").css("height", "70px");
                        $("#highlightBox").show();
                    }
                }
                box.translate(_x,_y,layer.parent,layer.xScale, layer.yScale);

                // Test to see if player scrolled the map in the downward direction
                ViewBox box = layer.parent.viewbox;
                if (box.x <= 265 && box.y >= 260 && tutorialIndex == 3) {
                    $("#tutorialTextDiv").show();
                    $("#instructionTextDiv").hide();
                    document.getElementById("instructionTextElement").innerHTML = instructionText[++instructionIndex];
                    advanceTutorial();
                }
            }
            if(mouseScroll!=0){
                if (GEN_TUTORIAL && tutorialIndex < 6) {
                    // do nothing
                } else {
                    layer.zoom(mouseScroll/10);
                    mouseScroll=0;
                }
            }
            if(isKeyDown('+') || isKeyDown('=')){
                if (GEN_TUTORIAL && tutorialIndex < 6) {
                    // do nothing
                } else {
                    layer.zoom(1/3/10);
                }
            }
            if(isKeyDown('-')){
                if (GEN_TUTORIAL && tutorialIndex < 6) {
                    // do nothing
                } else {
                    layer.zoom(-1/3/10);
                }
            }
            if(isKeyDown(' ')){                     //key is subject to change
                ViewBox box=layer.parent.viewbox;
                box.track(layer.parent,this);
            }
        }
        mouseScroll=0;
        keyCode=undefined;
    }
    void mouseDragged(int mx, int my, int button) {
        // If playing tutorial, disable scrolling until the tutorial explicitly
        // asks player to perform it and when the tutorial has concluded.
        if (GEN_TUTORIAL && (tutorialIndex < 3 || tutorialIndex == 36))
            return;
        else if (GEN_TUTORIAL && tutorialIndex == 3) {
            // Test to see if player scrolled the map in the downward direction
            ViewBox box = layer.parent.viewbox;
            if (box.x <= 265 && box.y >= 260) {
                $("#tutorialTextDiv").show();
                $("#instructionTextDiv").hide();
                document.getElementById("instructionTextElement").innerHTML = instructionText[++instructionIndex];
                advanceTutorial();
            }
        }
        super.mouseDragged(mx, my, button);
    }
    void mouseClicked(int mx, int my, int button) {
        // To prevent user from selecting and driving down roads
        // before a specific point in the tutorial is reached
        if (GEN_TUTORIAL && tutorialIndex < 37 && tutorialIndex != 31 && tutorialIndex != 11 &&
                tutorialIndex != 16 && tutorialIndex != 22 && tutorialIndex != 27 &&
                tutorialIndex != 35) return;

        if (!mapScreen) return;
        if (driveFlag) return;

        // The mouse co-ordinates must be offset by the position of the ViewBox
        // for scrolling and zooming to work properly
        var layerCoords = layer.mapCoordinateFromScreen(mx, my);
        mx = layerCoords[0];
        my = layerCoords[1];

        // Did we click on the vehicle? If not, check if we clicked on a road
        if (button == LEFT && over(mx,my)) {
            // Don't let the vehicle drive unless a number of roads have been selected
            // during the correct sections of the tutorial
            if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length < 2) return;
            if (GEN_TUTORIAL && tutorialIndex == 27 && destination.length < 2) return;
            if (GEN_TUTORIAL && tutorialIndex == 31 && destination.length < 2) return;
            if (destination.length == 1 ||
                    (destination.length > 0 && bonusTracker.initialBonusIndex == -1)) {
                driveToDestination();
            } else {
                if (destination.length > 0 && !showFractionBox) {
                    $("#fractionBoxDiv").show();
                    $("#fractionBonusImg").show();
                    $("#fractionBackImg").show();
                    $("#fracSumNum").focus();
                    $("#fuelWrap").hide();
                    showFractionBox = true;
                }
                // Change opacity of tutorial text div during the bonus overlay
                if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 2) {
                    document.getElementById("tutorialTextElement").innerHTML = tutorialText[++tutorialIndex];
                    $("#tutorialTextDiv").css("opacity", "1.0");
                    $("#highlightBox").css("left", "100px");
                    $("#highlightBox").css("top", "344px");
                    $("#highlightBox").css("width", "600px");
                    $("#highlightBox").css("height", "70px");
                    $("#highlightBox").show();
                }
            }
        // Prevents selecting more than 10 roads but allows right-clicks to
        // execute de-selection
        } else if (destination.length < 10 || button == RIGHT) {
            if (GEN_TUTORIAL && tutorialIndex == 11 && destination.length == 1) return;
            if (GEN_TUTORIAL && tutorialIndex == 16 && destination.length == 1) return;
            if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 2) return;
            if (GEN_TUTORIAL && tutorialIndex == 27 && destination.length == 2) return;
            if (GEN_TUTORIAL && tutorialIndex == 31 && destination.length == 2) return;
            if (GEN_TUTORIAL && tutorialIndex == 35 && destination.length == 1) return;
            // Get the hexadecimal colour code at the clicked point on the shadowMap
            color c = shadowMap.get(mx, my);
            c = hex(c);
            if (DISPLAY_SHADOWMAP) console.log(c);

            /* Clicking the left mouse button on a valid road segment highlights that segment and
             * updates the final destination for the vehicle to travel to. Clicking the right
             * mouse button on a valid road segment removes its highlight and updates the vehicle's
             * final destination to the previous node in the route.
             */
            if (shadowMapColorDictionary[c] != null && button == LEFT) {
                var flippedVertexX = shadowMapColorDictionary[c][0].vertex.x -
                    shadowMapColorDictionary[c][1].vertex.x > 0 ? true : false;
                var flippedVertexY = shadowMapColorDictionary[c][0].vertex.y -
                    shadowMapColorDictionary[c][1].vertex.y > 0 ? true : false;
                var fraction = null;

                if (shadowMapColorDictionary[c][0].vertex.equals(futurePosition)) {
                    // Tutorial checks
                    var vtx = shadowMapColorDictionary[c][1].vertex;
                    if (GEN_TUTORIAL && tutorialIndex == 16 && (vtx.x != 300 || vtx.y != 200)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 0 &&
                            (vtx.x != 300 || vtx.y != 300)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 1 &&
                            (vtx.x != 300 || vtx.y != 400)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 27 && destination.length == 0 &&
                            (vtx.x != 300 || vtx.y != 300)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 27 && destination.length == 1 &&
                            (vtx.x != 300 || vtx.y != 400)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 31 && destination.length == 0 &&
                            (vtx.x != 400 || vtx.y != 400)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 31 && destination.length == 1 &&
                            (vtx.x != 400 || vtx.y != 500)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 35 && destination.length == 0 &&
                            (vtx.x != 400 || vtx.y != 800)) return;

                    destination.push(shadowMapColorDictionary[c][1]);
                    if (!flippedVertexX && !flippedVertexY) {
                        roadSelectedDictionary[c][0] += 1;
                    } else if (flippedVertexX || flippedVertexY) {
                        roadSelectedDictionary[c][1] += 1;
                    }
                    fraction = shadowMapColorDictionary[c][0].connections[destination[destination.length - 1].id];
                    futurePosition = shadowMapColorDictionary[c][1].vertex;
                    var st = nodeMap.pjsStructureList[shadowMapColorDictionary[c][1].id];
                    if (st) {
                        if (st.structObject.StructType != "fuel_stn" && !st.structObject.visited) {
                            bonusTracker.array.push(true);
                            if (bonusTracker.initialBonusIndex == -1) {
                                bonusTracker.initialBonusIndex = bonusTracker.array.length - 1;
                            }
                        } else {
                            bonusTracker.array.push(false);
                        }
                    } else {
                        bonusTracker.array.push(false);
                    }
                    currDestColorID.push(c);

                    if (destination.length > 1) {
                        fractionCT.innerHTML += "<div style=\"float:left;padding-top:29px;\">+</div>" +
                            "<div style=\"margin:1px;float:left;width:45px;\">" +
                            "<div id=\"fraction" + destination.length +
                            "\" style=\"text-align:center;margin:10px;\"></div></div>";

                        var fracElement = document.getElementById("fraction" + destination.length);
                        fracElement.innerHTML = fraction.displayNum != undefined ? fraction.displayNum.toString() :
                            fraction.numerator.toString();
                        fracElement.innerHTML += "<br /><hr />";
                        fracElement.innerHTML += fraction.displayDenom != undefined ?
                            fraction.displayDenom.toString() : fraction.denominator.toString();

                        fractionArray.push(fraction);
                    }
                } else if (shadowMapColorDictionary[c][1].vertex.equals(futurePosition)) {
                    // Tutorial checks
                    var vtx = shadowMapColorDictionary[c][0].vertex;
                    if (GEN_TUTORIAL && tutorialIndex == 16 && (vtx.x != 300 || vtx.y != 200)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 0 &&
                            (vtx.x != 300 || vtx.y != 300)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 1 &&
                            (vtx.x != 300 || vtx.y != 400)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 27 && destination.length == 0 &&
                            (vtx.x != 300 || vtx.y != 300)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 27 && destination.length == 1 &&
                            (vtx.x != 300 || vtx.y != 400)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 31 && destination.length == 0 &&
                            (vtx.x != 400 || vtx.y != 400)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 31 && destination.length == 1 &&
                            (vtx.x != 400 || vtx.y != 500)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 35 && destination.length == 0 &&
                            (vtx.x != 400 || vtx.y != 800)) return;

                    destination.push(shadowMapColorDictionary[c][0]);
                    if (!flippedVertexX && !flippedVertexY) {
                        roadSelectedDictionary[c][1] += 1;
                    } else if (flippedVertexX || flippedVertexY) {
                        roadSelectedDictionary[c][0] += 1;
                    }
                    fraction = shadowMapColorDictionary[c][1].connections[destination[destination.length - 1].id];
                    futurePosition = shadowMapColorDictionary[c][0].vertex;
                    var st = nodeMap.pjsStructureList[shadowMapColorDictionary[c][0].id];
                    if (st) {
                        if (st.structObject.StructType != "fuel_stn" && !st.structObject.visited) {
                            bonusTracker.array.push(true);
                            if (bonusTracker.initialBonusIndex == -1) {
                                bonusTracker.initialBonusIndex = bonusTracker.array.length - 1;
                            }
                        } else {
                            bonusTracker.array.push(false);
                        }
                    } else {
                        bonusTracker.array.push(false);
                    }
                    currDestColorID.push(c);

                    if (destination.length > 1) {
                        fractionCT.innerHTML += "<div style=\"float:left;padding-top:29px;\">+</div>" +
                            "<div style=\"margin:1px;float:left;width:45px;\">" +
                            "<div id=\"fraction" + destination.length +
                            "\" style=\"text-align:center;margin:10px;\"></div></div>";

                        var fracElement = document.getElementById("fraction" + destination.length);
                        fracElement.innerHTML = fraction.displayNum != undefined ? fraction.displayNum.toString() :
                            fraction.numerator.toString();
                        fracElement.innerHTML += "<br /><hr />";
                        fracElement.innerHTML += fraction.displayDenom != undefined ?
                            fraction.displayDenom.toString() : fraction.denominator.toString();

                        fractionArray.push(fraction);
                    }
                }
                if (fraction != null && destination.length == 1) {
                    if (GEN_TUTORIAL && tutorialIndex == 11) {
                        document.getElementById("instructionTextElement").innerHTML = instructionText[++instructionIndex];
                    }
                    fractionText.innerHTML = "<div id=\"fractionCT\" class=\"inCanvas\"" +
                        "style=\"position:absolute;width:80%;\"></div><div id=\"submitDiv\"" +
                        "style=\"position:absolute;left:80%;width:20%;\"></div>";
                    fractionCT = document.getElementById("fractionCT");
                    fractionCT.innerHTML = "<div style=\"margin:1px;float:left;width:45px;\">" +
                        "<div id=\"fraction" + destination.length +
                        "\" style=\"text-align:center;margin:10px;\"></div></div>";

                    // Add the div containing the input textboxes to the overlay
                    var submitBox = document.getElementById("submitDiv");
                    submitBox.innerHTML += "<div style=\"margin:1px;float:right;width:70px;\">" +
                        "<div id=\"fractionSubmit\"" +
                        "style=\"width:64px;height:64px;background-color:white;margin:5px;\"" +
                        "onclick=\"checkFractionSum()\" >" +
                        "<img src=\"./assets/items/drive_btn.png\" width=\"64px\" height=\"64px\"/></div></div>" +
                        "<div style=\"margin:1px;float:right;width:45px;\">" +
                        "<div id=\"fractionSum\" style=\"text-align:center;\"></div></div>" +
                        "<div style=\"float:right;padding-top:29px;\">=</div>";

                    var fracElement = document.getElementById("fraction" + destination.length);
                    fracElement.innerHTML = fraction.displayNum != undefined ? fraction.displayNum.toString() :
                        fraction.numerator.toString();
                    fracElement.innerHTML += "<br /><hr />";
                    fracElement.innerHTML += fraction.displayDenom != undefined ?
                        fraction.displayDenom.toString() : fraction.denominator.toString();

                    fractionArray.push(fraction);

                    var fracSum = document.getElementById("fractionSum");
                    fracSum.innerHTML = "<div id=\"fractionNum\" style=\"padding:1px;margin:3px;border-radius:3px;\"><input type=\"text\" id=\"fracSumNum\" name=\"numerator\" autocomplete=\"off\" onblur=\"testInput(this)\"" +
                        "onfocus=\"fracHideTooltip(this)\" style=\"width:23px\" /></div>" +
                        "<hr />" +
                        "<div id=\"fractionDenom\" style=\"margin:3px;border-radius:3px;\"><input type=\"text\" id=\"fracSumDenom\" name=\"denominator\" autocomplete=\"off\" onblur=\"testInput(this)\"" +
                        "onfocus=\"fracHideTooltip(this)\" style=\"width:23px\" /></div>";
                }
            } else if (shadowMapColorDictionary[c] != null && button == RIGHT) {
                var prevDest, index, delta = 0;

                if (destination.length > 1) {
                    prevDest = destination[destination.length - 2].vertex;
                } else if (destination.length == 1) {
                    prevDest = currentPosition;
                } else {
                    return;
                }

                if (futurePosition.x - prevDest.x == 0) {
                    delta = futurePosition.y - prevDest.y;
                    index = delta < 0 ? 1 : 0;
                } else if (futurePosition.y - prevDest.y == 0) {
                    delta = futurePosition.x - prevDest.x;
                    index = delta < 0 ? 1 : 0;
                }

                if (roadSelectedDictionary[c][index] > 0 &&
                        c == currDestColorID[currDestColorID.length - 1]) {

                    roadSelectedDictionary[c][index] -= 1;
                    destination.pop();
                    fractionArray.pop();
                    bonusTracker.array.pop();
                    if (bonusTracker.array.length <= bonusTracker.initialBonusIndex) {
                        bonusTracker.initialBonusIndex = -1;
                    }
                    if (destination.length > 0) {
                        futurePosition = destination[destination.length - 1].vertex;

                        // Remove the div elements containing the fraction and the "+" sign
                        var node = fractionCT.children[fractionCT.childElementCount - 1];
                        node.parentNode.removeChild(node);
                        node = fractionCT.children[fractionCT.childElementCount - 1];
                        node.parentNode.removeChild(node);
                    } else {
                        futurePosition = currentPosition;
                        $("#fuelWrap").show();
                        fractionText.innerHTML = "";
                    }
                    currDestColorID.pop();
                }
            }
        }
    }
}
class MapLevel extends LevelLayer {
    var generatedMap = null;
    var r = 0, g = 0, b = 0;
    var shadowBounds = [];
    var structList = [];

    MapLevel(Level owner, map) {
        super(owner);
        shadowMap = null;
        shadowMapColorDictionary = {};
        roadSelectedDictionary = {};
        shadowMap = createGraphics(screenWidth * 2, screenHeight * 2, JAVA2D);
        generatedMap = map;
        setBackgroundColor(color(197, 233, 203));
        initializeRoads();
    }
    void zoom(float s) {
        if (GEN_TUTORIAL && tutorialIndex == 6) {
            $("#tutorialTextDiv").show();
            $("#instructionTextDiv").hide();
            document.getElementById("instructionTextElement").innerHTML = instructionText[++instructionIndex];
            advanceTutorial();
        }
        if (xScale + s < 0.7) {
            setScale(0.7);
            zoomLevel = 1.3;
        } else if (xScale + s > 1.6) {
            setScale(1.6);
            zoomLevel = 0.4;
        } else {
            setScale(xScale + s);
            zoomLevel -= s;
        }
    }
    // Calculate the shadow road vertices
    void calculateShadowBounds(vertex1, vertex2) {
        var vFlippedX = (vertex1.x - vertex2.x) < 0 ? false : true;
        var vFlippedY = (vertex1.y - vertex2.y) < 0 ? false : true;
        if (vertex1.x - vertex2.x == 0 && !vFlippedY) {
            shadowBounds[0] = vertex1.x;
            shadowBounds[1] = vertex1.y + 17;
            shadowBounds[2] = vertex2.x;
            shadowBounds[3] = vertex2.y - 17;
        } else if (vertex1.x - vertex2.x == 0 && vFlippedY) {
            shadowBounds[0] = vertex1.x;
            shadowBounds[1] = vertex2.y + 17;
            shadowBounds[2] = vertex2.x;
            shadowBounds[3] = vertex1.y - 17;
        }
        if (vertex1.y - vertex2.y == 0 && !vFlippedX) {
            shadowBounds[0] = vertex1.x + 17;
            shadowBounds[1] = vertex1.y;
            shadowBounds[2] = vertex2.x - 17;
            shadowBounds[3] = vertex2.y;
        } else if (vertex1.y - vertex2.y == 0 && vFlippedX) {
            shadowBounds[0] = vertex2.x + 17;
            shadowBounds[1] = vertex1.y;
            shadowBounds[2] = vertex1.x - 17;
            shadowBounds[3] = vertex2.y;
        }
    }
    void initializeRoads() {
        var edgeList = generatedMap.getEdgeList();

        shadowMap.beginDraw();
        shadowMap.background(255);
        shadowMap.strokeWeight(25);

        for (index in edgeList) {
            var primaryNode = generatedMap.mapGraph.nodeDictionary[index];

            for (var i = edgeList[index].length - 1; i >= 0; i--) {
                var connectedNode = generatedMap.mapGraph.findNodeArray(edgeList[index][i]);
                var fraction = primaryNode.connections[edgeList[index][i]];

                // Generate a new colour for the road segment, then draw the segment in that colour
                color shadowColor = color(r, g, b);
                shadowMap.stroke(shadowColor);
                calculateShadowBounds(primaryNode.vertex, connectedNode.vertex);
                shadowMap.line(shadowBounds[0], shadowBounds[1], shadowBounds[2], shadowBounds[3]);

                // Store the nodes that make up the edge using its color as the ID
                var colorID = hex(shadowColor);
                shadowMapColorDictionary[colorID] = [];
                shadowMapColorDictionary[colorID].push(primaryNode);
                shadowMapColorDictionary[colorID].push(connectedNode);

                // Create and add the road segment to the level
                Road roadSegment = new Road(colorID, primaryNode.vertex, connectedNode.vertex, fraction);
                addInteractor(roadSegment);

                // Initialize road selected values
                roadSelectedDictionary[colorID] = [];
                roadSelectedDictionary[colorID][0] = 0;
                roadSelectedDictionary[colorID][1] = 0;

                // Increment color values for the shadow roads; stay within bounds
                if (r >= 255) { r = 0; g++; }
                else { r++; }
                if (g > 255) { r = 0; g = 0; b++; }
                // If the blue component goes beyond 255, we have run out of unique colours to
                // use to identify road segments
                if (b > 255) { console.error("Ran out of colours for road segments!"); }
            }
        }
        shadowMap.endDraw();
        shadowBounds = [];
        initializePlayer();
        if(debugging){
            var allNodes=generatedMap.mapGraph.nodeDictionary;
            for(index in allNodes){
                NodeDebug tmp = new NodeDebug(allNodes[index].vertex, index);
                addInteractor(tmp);
            }
        }
    }
    void initializeStructures(fuelCost) {
        var structureListLength = generatedMap.structureList.length;
        for(var i = 0; i < structureListLength; i++) {
            var structObject = generatedMap.structureList[i];
            var vert = generatedMap.mapGraph.findNodeArray(structObject.nodeID).vertex;

            Struct structure = new Struct(vert,structObject, generatedMap.fuel.denominator, fuelCost);
            addInputInteractor(structure);
            structList.push(structure);
            generatedMap.pjsStructureList[structObject.nodeID]=structure;
        }
    }
    void initializePlayer() {
        player = GEN_TUTORIAL ? new TutorialDriver(generatedMap) : new Driver(generatedMap);
        addPlayer(player);
        parent.viewbox.track(parent,player);
        var depot = new Depot(generatedMap.startPoint.clone());
        addInteractor(depot);
        initializeStructures(player.fuelCost);
    }
    void resetMap(){
        gameOver = false;
        $("#fractionBoxDiv").hide();
        $("#fractionBonusImg").hide();
        $("#fractionBackImg").hide();
        for (var i in roadSelectedDictionary) {
            roadSelectedDictionary[i][0] = 0;
            roadSelectedDictionary[i][1] = 0;
        }
        document.getElementById("fuelElement2").style.cssText = "color:white";
        for (var i = structList.length; i--;) {
            structList[i].resetState();
        }
        levelCash = 0;
        fractionArray.length = 0;
        deliveriesLeft = levelToDeliveries(currentLevel);
        clearPlayers();
        player = new Driver(generatedMap);
        addPlayer(player);
        for(index in generatedMap.pjsStructureList){
            generatedMap.pjsStructureList[index].structObject.visited=false;
            generatedMap.pjsStructureList[index].setTransparency(255);
        }
        setScale(1);
        zoomLevel=1;
        parent.viewbox.track(parent,player);
    }
}
/**
 *  Handles drawing of roads and their fraction values.
 */

class Road extends Interactor {
    var vertex1;
    var vertex2;

    PFont fracFont;
    var fracText = "";
    var currX = 0, currY = 0, textPosX, textPosY;
    var roadBounds = [], roadSelection = [], roadSelection2 = [];
    var cID, vFlippedX, vFlippedY, horizontal, vertical;
    Road(id, vert1, vert2, frac) {
        super("Road");
        vertex1 = vert1;
        vertex2 = vert2;
        fracFont = loadFont("EurekaMonoCond-Bold.ttf");
        textFont(fracFont, 14);
        textLeading(9);
        if(gameDifficulty>1 || currentLevel==5){
            if(rng(1,10)<=(2+gameDifficulty+currentLevel))
               frac.genAltDisplay();
        }
        fracText = frac.toString();
        //fracText = frac.numerator.toString() + "\n—\n" + frac.denominator.toString();
        // Associate the road segment with its shadowMap road's hexadecimal colour code
        cID = id;
        horizontal = vertex1.y - vertex2.y == 0 ? true : false;
        vertical = vertex1.x - vertex2.x == 0 ? true : false;
        textPosX = vertical ? vertex1.x + 12 : (vertex1.x + vertex2.x) * 0.5;
        textPosY = horizontal ? vertex1.y - 32 : (vertex1.y + vertex2.y) * 0.5;
        calculateBounds();
    }
    // Calculate the box that acts as the highlight for the road segment
    void calculateBounds() {
        vFlippedX = (vertex1.x - vertex2.x) <= 0 ? false : true;
        vFlippedY = (vertex1.y - vertex2.y) <= 0 ? false : true;
        if (vertex1.x - vertex2.x == 0 && !vFlippedY) {
            roadSelection[0] = vertex1.x - 9;
            roadSelection[1] = vertex1.y + 30;
            roadSelection[2] = vertex2.x - 3;
            roadSelection[3] = vertex2.y - 50;
            roadSelection[4] = vertex2.x - 6;
            roadSelection[5] = vertex2.y - 40;
            roadSelection[6] = vertex1.x - 9;
            roadSelection[7] = vertex2.y - 50;
            roadSelection[8] = vertex2.x - 3;
            roadSelection[9] = vertex2.y - 50;
            roadSelection2[0] = vertex1.x + 3;
            roadSelection2[1] = vertex1.y + 50;
            roadSelection2[2] = vertex2.x + 9;
            roadSelection2[3] = vertex2.y - 30;
            roadSelection2[4] = vertex1.x + 6;
            roadSelection2[5] = vertex1.y + 40;
            roadSelection2[6] = vertex1.x + 9;
            roadSelection2[7] = vertex1.y + 50;
            roadSelection2[8] = vertex1.x + 3;
            roadSelection2[9] = vertex1.y + 50;
            roadBounds[0] = vertex1.x - 12;
            roadBounds[1] = vertex1.y + 11;
            roadBounds[2] = vertex2.x + 12;
            roadBounds[3] = vertex2.y - 11;
        } else if (vertex1.x - vertex2.x == 0 && vFlippedY) {
            roadSelection[0] = vertex2.x - 9;
            roadSelection[1] = vertex2.y + 30;
            roadSelection[2] = vertex1.x - 3;
            roadSelection[3] = vertex1.y - 50;
            roadSelection[4] = vertex1.x - 6;
            roadSelection[5] = vertex1.y - 40;
            roadSelection[6] = vertex1.x - 9;
            roadSelection[7] = vertex1.y - 50;
            roadSelection[8] = vertex1.x - 3;
            roadSelection[9] = vertex1.y - 50;
            roadSelection2[0] = vertex2.x + 3;
            roadSelection2[1] = vertex2.y + 50;
            roadSelection2[2] = vertex1.x + 9;
            roadSelection2[3] = vertex1.y - 30;
            roadSelection2[4] = vertex2.x + 6;
            roadSelection2[5] = vertex2.y + 40;
            roadSelection2[6] = vertex2.x + 9;
            roadSelection2[7] = vertex2.y + 50;
            roadSelection2[8] = vertex2.x + 3;
            roadSelection2[9] = vertex2.y + 50;
            roadBounds[0] = vertex1.x - 12;
            roadBounds[1] = vertex2.y + 11;
            roadBounds[2] = vertex2.x + 12;
            roadBounds[3] = vertex1.y - 11;
        }
        if (vertex1.y - vertex2.y == 0 && !vFlippedX) {
            roadSelection[0] = vertex1.x + 30;
            roadSelection[1] = vertex1.y + 3;
            roadSelection[2] = vertex2.x - 50;
            roadSelection[3] = vertex2.y + 9;
            roadSelection[4] = vertex2.x - 40;
            roadSelection[5] = vertex2.y + 6;
            roadSelection[6] = vertex2.x - 50;
            roadSelection[7] = vertex1.y + 3;
            roadSelection[8] = vertex2.x - 50;
            roadSelection[9] = vertex2.y + 9;
            roadSelection2[0] = vertex1.x + 50;
            roadSelection2[1] = vertex1.y - 9;
            roadSelection2[2] = vertex2.x - 30;
            roadSelection2[3] = vertex2.y - 3;
            roadSelection2[4] = vertex1.x + 40;
            roadSelection2[5] = vertex1.y - 6;
            roadSelection2[6] = vertex1.x + 50;
            roadSelection2[7] = vertex1.y - 9;
            roadSelection2[8] = vertex1.x + 50;
            roadSelection2[9] = vertex2.y - 3;
            roadBounds[0] = vertex1.x + 11;
            roadBounds[1] = vertex1.y - 12;
            roadBounds[2] = vertex2.x - 11;
            roadBounds[3] = vertex2.y + 12;
        } else if (vertex1.y - vertex2.y == 0 && vFlippedX) {
            roadSelection[0] = vertex2.x + 30;
            roadSelection[1] = vertex2.y + 3;
            roadSelection[2] = vertex1.x - 50;
            roadSelection[3] = vertex1.y + 9;
            roadSelection[4] = vertex1.x - 40;
            roadSelection[5] = vertex1.y + 6;
            roadSelection[6] = vertex1.x - 50;
            roadSelection[7] = vertex1.y + 3;
            roadSelection[8] = vertex1.x - 50;
            roadSelection[9] = vertex1.y + 9;
            roadSelection2[0] = vertex2.x + 50;
            roadSelection2[1] = vertex2.y - 9;
            roadSelection2[2] = vertex1.x - 30;
            roadSelection2[3] = vertex1.y - 3;
            roadSelection2[4] = vertex2.x + 40;
            roadSelection2[5] = vertex2.y - 6;
            roadSelection2[6] = vertex2.x + 50;
            roadSelection2[7] = vertex2.y - 9;
            roadSelection2[8] = vertex2.x + 50;
            roadSelection2[9] = vertex2.y - 3;
            roadBounds[0] = vertex2.x + 11;
            roadBounds[1] = vertex1.y - 12;
            roadBounds[2] = vertex1.x - 11;
            roadBounds[3] = vertex2.y + 12;
        }
    }
    void drawSelectionEastSouth() {
        // Draw the arrow
        fill(51,206,195);
        rect(roadSelection[0], roadSelection[1], roadSelection[2] - roadSelection[0],
                roadSelection[3] - roadSelection[1]);
        triangle(roadSelection[4], roadSelection[5], roadSelection[6], roadSelection[7],
                roadSelection[8], roadSelection[9]);

        // Draw number denoting how many times the vehicle will drive in that direction
        if (roadSelectedDictionary[cID][0] > 0) {
            fill(0);
            textAlign(LEFT, CENTER);
            if (horizontal) {
                text(roadSelectedDictionary[cID][0].toString(), roadSelection[4]-18, roadSelection[5]+10);
            } else {
                text(roadSelectedDictionary[cID][0].toString(), roadSelection[4]-15, roadSelection[5]-10);
            }
            textAlign(LEFT);
        }
    }
    void drawSelectionWestNorth() {
        // Draw the arrow
        fill(51,206,195);
        rect(roadSelection2[0], roadSelection2[1], roadSelection2[2] - roadSelection2[0],
                roadSelection2[3] - roadSelection2[1]);
        triangle(roadSelection2[4], roadSelection2[5], roadSelection2[6], roadSelection2[7],
                roadSelection2[8], roadSelection2[9]);

        // Draw number denoting how many times the vehicle will drive in that direction
        if (roadSelectedDictionary[cID][1] > 0) {
            fill(0);
            textAlign(LEFT, CENTER);
            if (horizontal) {
                text(roadSelectedDictionary[cID][1].toString(), roadSelection[4]-28, roadSelection[5]-20);
            } else {
                text(roadSelectedDictionary[cID][1].toString(), roadSelection[4]+10, roadSelection[5]-30);
            }
            textAlign(LEFT);
        }
    }
    void draw(float v1x,float v1y,float v2x, float v2y){
        if(debugging)
            stroke(0,0,0);
        line(vertex1.x, vertex1.y, vertex2.x, vertex2.y);

        // If the road has been selected or the mouse is within the road bounds,
        // draw the road highlight in the valid direction
        if (roadSelectedDictionary != null && roadSelectedDictionary[cID][0] > 0) {
            noStroke();
            drawSelectionEastSouth();
            stroke(0);
        }
        if (roadSelectedDictionary != null && roadSelectedDictionary[cID][1] > 0) {
            noStroke();
            drawSelectionWestNorth();
            stroke(0);
        }

        // Render the fraction text next to the road segment and highlight the direction
        // the vehicle will travel in (if the road is adjacent to the vehicle's current location)
        fill(126);
        if (!driveFlag && (mouseOffsetX >= roadBounds[0] && mouseOffsetX <= roadBounds[2] &&
                mouseOffsetY >= roadBounds[1] && mouseOffsetY <= roadBounds[3])) {

            if (futurePosition.x == vertex1.x && futurePosition.y == vertex1.y) {
                noStroke();
                if (!vFlippedX && !vFlippedY) {
                    drawSelectionEastSouth();
                } else if (vFlippedX || vFlippedY) {
                    drawSelectionWestNorth();
                }
                stroke(0);
            } else if (futurePosition.x == vertex2.x && futurePosition.y == vertex2.y) {
                noStroke();
                if (!vFlippedX && !vFlippedY) {
                    drawSelectionWestNorth();
                } else if (vFlippedX || vFlippedY) {
                    drawSelectionEastSouth();
                }
                stroke(0);
            }
            fill(0);
        }
        textAlign(CENTER);
        text(fracText, textPosX, textPosY);
        textAlign(LEFT);
        fill(126);
        if (DISPLAY_SHADOWMAP) image(shadowMap, 0, 0);
    }
}
/*
	Generates a new map. This does not increment the current level.
*/
void newMap(){
    if (debugging) console.log("==========================================");
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
/**
 *  Screens other then the main game.
 */

class TitleScreen extends Level {
    TitleScreen(int sWidth, int sHeight) {
        super(sWidth, sHeight);
        addLevelLayer("Title Screen Layer", new TitleScreenLayer(this));
    }
}

class TitleScreenLayer extends LevelLayer {
    TitleScreenLayer(Level owner) {
        super(owner);
        addBackgroundSprite(new TilingSprite(
            new Sprite(assetsFolder+"titleScreenPlaceholder.png"), 0, 0, screenWidth, screenHeight));
    }
}

class WinScreen extends LevelLayer {
    WinScreen(Level owner) {
        super(owner);
        alert("Winner!");
    }
}

class GameOverScreen extends LevelLayer {
    GameOverScreen(Level owner) {
        super(owner);
        alert("Game Over. Try Again!");
    }
}
/*
 *  Intermediate campaign screen
 */
class VehicleOption extends InputInteractor{
    static int height = 300;
    static int width = 150;
    static int padding = 19;
    var type;
    int x;
    boolean selected;
    VehicleOption(var _type){
        super("Vehicle Option");
        type=_type;
        x = (type-1)*(width+padding*2)+padding+(width/2);
        setPosition(x,height);
        selected = false;
        setStates();
    }
    void setStates(){
        addState(new State("default",assetsFolder+"vehicles/"+vehicleTypes[type][1]));
    }
    void mouseClicked(int mx, int my, int button){
        if(over(mx,my) && carInventory.indexOf(type) > -1){
            currentVehicle = type;
        }
    }
    void purchase(){
        if(campaignCash - vehicleCosts[type] > 0){
            campaignCash = campaignCash - vehicleCosts[type];
            carInventory.push(type);
            currentVehicle = type;
            $("#campaignCashText").text("$"+campaignCash);
        }
    }
    void drawObject() {
        super.drawObject();
        if(currentVehicle == type){
            noFill();
            rect(-width/2,-height/2,width,height);
        }
    }
}
class buyVehicle extends InputInteractor{
    int x, y;
    var vehicle;
    buyVehicle(var _vehicle){
        super("Buy Button");
        vehicle = _vehicle;
        x = vehicle.x;
        y = vehicle.height+vehicle.height/2+vehicle.padding;
        setPosition(x,y);
        setStates();
    }
    void setStates(){
        addState(new State("default",assetsFolder+"placeholders/buyButton.png"));
    }
    void mouseClicked(int mx, int my, int button){
        if(over(mx,my) && carInventory.indexOf(vehicle.type)==-1){
            vehicle.purchase();
        }
    }
    void drawObject(){
        super.drawObject();
        if(carInventory.indexOf(vehicle.type)>-1)
            text("Purchased",0,0);
        else
            text("$"+vehicleCosts[vehicle.type],0,0);
    }
}
class InterScreen extends Level {
    InterScreen(int sWidth, int sHeight){
        super(sWidth, sHeight);
        InterScreenLayer layer = new InterScreenLayer(this);
        addLevelLayer("Inter Screen Layer", layer);
        layer.onReady();
    }
}
class InterScreenLayer extends LevelLayer {
    InterScreenLayer(Level owner){
        super(owner);
        setBackgroundColor(color(197, 233, 203));
    }
    void onReady(){
        VehicleOption v1 = new VehicleOption(1),
        v2 = new VehicleOption(2),
        v3 = new VehicleOption(3),
        v4 = new VehicleOption(4),
        v5 = new VehicleOption(5);
        addInputInteractor(v1);
        addInputInteractor(v2);
        addInputInteractor(v3);
        addInputInteractor(v4);
        addInputInteractor(v5);
        //Add purchase buttons
        addInputInteractor(new buyVehicle(v1));
        addInputInteractor(new buyVehicle(v2));
        addInputInteractor(new buyVehicle(v3));
        addInputInteractor(new buyVehicle(v4));
        addInputInteractor(new buyVehicle(v5));

    }
}
/**
 *  Handles drawing of all structures.
 */

class Depot extends Interactor {
    var vertex;
    Depot(vert){
        super("Depot");
        setPosition(vert.x, vert.y);
        vertex=vert;
        setStates();
    }
    void setStates(){
        setScale(0.5);
        addState(new State("default",structureFolder+"depot_default.png"));
    }
}
class Struct extends InputInteractor {
    var vertex, sBox, structObject, delivered;
    var hovering, fuelCaption;
    Struct(vert, _structObject, tankDenominator, costOfFuel) {
        super("Structure");
        setPosition(vert.x, vert.y);
        vertex = vert;
        hovering = false;
        structObject=_structObject;
        setStates();
        sBox = getBoundingBox();
        fuelCaption = "";
        if (structObject.StructType == "fuel_stn") {
            fuelCaption = "Costs $" + costOfFuel.toString() + " per 1/" + tankDenominator.toString();
        }
    }
    void setStates() {
        setScale(0.5);
        delivered = false;
        addState(new State("delivered",structureFolder+structObject.StructType+"_50.png"));
        addState(new State("default",structureFolder+structObject.StructType+".png"));
    }
    void resetState() {
        delivered = false;
        swapStates(getState("default"));
    }
    void draw(float v1x,float v1y,float v2x, float v2y){
        super.draw(v1x,v1y,v2x,v2y);
        if (!delivered && structObject.visited && structObject.StuctType != "fuel_stn") {
            delivered = true;
            swapStates(getState("delivered"));
        }
        if (structObject.StructType == "fuel_stn") {
            if (refueled && structObject.visited) {
                swapStates(getState("delivered"));
            } else if (!refueled && structObject.visited) {
                structObject.visited = false;
                swapStates(getState("default"));
            }
        }
        if (hovering) {
            noStroke();
            fill(0, 0, 0, 170);
            rect(sBox[0] - 19, sBox[1] - 23, 110, 30);
            if (structObject.StructType == "fuel_stn") {
                rect(sBox[0] - 39, sBox[1] + 60, 150, 30);
            } else {
                rect(sBox[0] - 8, sBox[1] + 60, 90, 30);
            }
            fill(255);
            textAlign(CENTER);
            text(structObject.StructCaption, sBox[0] - 19, sBox[1] - 14, 110, 30);
            if (structObject.StructType == "fuel_stn") {
                text(fuelCaption, sBox[0] - 39, sBox[1] + 68, 150, 30);
            } else {
                text(structObject.visited ? "Delivered" : "$"+structObject.pointsString(),
                        sBox[0] - 8, sBox[1] + 68, 90, 30);
            }
            stroke(0);
            textAlign(LEFT);
        }
    }
    void mouseMoved(int mx, int my) {
        if (!mapScreen) return;

        // The mouse co-ordinates must be offset by the position of the ViewBox
        // for scrolling and zooming to work properly
        var layerCoords = layer.mapCoordinateFromScreen(mx, my);
        mx = layerCoords[0];
        my = layerCoords[1];

        // For detecting if we've hovered over a road
        mouseOffsetX = mx;
        mouseOffsetY = my;

        if (over(mx, my)) {
            if (!player.currentPosition.equals(vertex)) {
                hovering = true;
                setScale(0.7);
            }
        } else if (hovering) {
            hovering = false;
            setScale(0.5);
        }
    }
}
/*
**  Debugging Classes. Remove at release.
 */
class NodeDebug extends Interactor{
    var vertex,flag;
    NodeDebug(vert,flagin){
        super("Node");
        vertex=vert;
        flag=flagin;
    }
    void draw(float v1x,float v1y,float v2x, float v2y){
        pushMatrix();
        //scale(zoomLevel);
        fill(0,0,255);
        if(flag)
            stroke(0,0,255);
        else
            stroke(255,0,0);
        text(flag, vertex.x+4, vertex.y-2);
        //ellipse(vertex.x,vertex.y,8,8);
        popMatrix();
    }
}
