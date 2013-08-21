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
float zoomLevel = 1.0;
int arrowSpeed=10;

//tracking game values
int gameDifficulty = 1;
int currentLevel = 1;       //change difficuly or level from 1 & 1 to generate a map, rather then the tutorial
int levelCash = 0;
int campaignCash = 0;
int deliveriesLeft = 0;
var mapScreen = false;
var gameOver = false;
var refueled = false;
var driveFlag;

//line width
strokeWeight(4);

/*debugging tools*/
boolean debugging=false;
var GEN_TUTORIAL=false;
var showMenus=false;

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

/*  NEEDS TO BE REWRITTEN
void loadDifficulty(diffVal, gameMode) {
    gameDifficulty = diffVal;

    if (gameMode == "Campaign") {
        if (diffVal == 1) {
            // Change to correct screen later
            //addScreen("testing",new XMLLevel(screenWidth*2,screenHeight*2,new Map("map.xml")));
            addScreen("testing", new CampaignMap(screenWidth * 2, screenHeight * 2));
            setActiveScreen("testing");
        } else if (diffVal == 2) {
            // Change to correct screen later
            addScreen("testing",new XMLLevel(screenWidth*2,screenHeight*2,new Map(0,0,"map.xml")));
            setActiveScreen("testing");
        } else if (diffVal == 3) {
            // Change to correct screen later
            addScreen("testing",new XMLLevel(screenWidth*2,screenHeight*2,new Map(0,0,"map.xml")));
            setActiveScreen("testing");
        } else {
            console.error("Invalid difficulty! Cannot load map.");
        }
    } else if (gameMode == "Quick Play") {
        alert("Not implemented yet!");
    } else {
        console.error("Undefined game mode!");
    }
}
*/

void initialize() {
    sketch = Processing.instances[0];
    clearScreens(); // reset the screen
    if(showMenus){
        addScreen("Title Screen", new TitleScreen(screenWidth, screenHeight));
        setActiveScreen("Title Screen"); // useful for when more screens are added
    }
    addScreen("testing",new CampaignMap(screenWidth*2,screenHeight*2));
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
        deliveriesLeft = 4;
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
    void draw() {
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
}

class MapLevel extends LevelLayer {
    var generatedMap = null;
    var r = 0, g = 0, b = 0;
    var shadowBounds = [];

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
            if (debugging)
                StructDebug structure = new StructDebug(vert,structObject);
            else
                Struct structure = new Struct(vert,structObject, generatedMap.fuel.denominator, fuelCost);
            addInputInteractor(structure);
            generatedMap.pjsStructureList[structObject.nodeID]=structure;
		}
    }
    void initializePlayer() {
        player = new Driver(generatedMap);
        addPlayer(player);
        var depot = new Depot(generatedMap.startPoint.clone());
        addInteractor(depot);
        depot.setTransparency(128);
        initializeStructures(player.fuelCost);
    }
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
        fuelGauge = new Fraction(nodeMap.fuel.numerator, nodeMap.fuel.denominator);
        fuelGaugeHUD = document.getElementById("fuelElement2");
        fuelGaugeHUD.innerHTML = fuelGauge.numerator.toString();
        fuelGaugeHUD.innerHTML += "<br /><hr />";
        fuelGaugeHUD.innerHTML += fuelGauge.denominator.toString();
        needleDelta = NEEDLE_RANGE / fuelGauge.denominator;
        fuelNeedleHUD = document.getElementById("fuelNeedleDiv");
        cashHUD = document.getElementById("cashElement");
        cashHUD.innerHTML = "$" + levelCash;
        parcelHUD = document.getElementById("parcelElement");
        parcelHUD.innerHTML = "x " + deliveriesLeft;
        var fuelCostWeight = 1.0 - (0.6 - gameDifficulty * 0.2);
        fuelCost = Math.floor(StructureValues.fuel_stn * fuelCostWeight / fuelGauge.denominator);
        setScale(0.8);
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
                    advanceTutorial();
                }
                box.translate(_x,_y,layer.parent);
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
    void mouseMoved(int mx, int my){
        canvasHasFocus=true;
    }
    void driveToDestination() {

        var impulseX = 0, impulseY = 0;

        refueled = false;
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

        if(structureCheck(startNode.id))
            nodeMap.pjsStructureList[startNode.id].setTransparency(255);
        // Calculate the distance that the vehicle travels
        // across the current edge on one "tick" of fuel
        deltaPerTick = edgeDelta / destinationWeight.numerator;

        driveFlag = true;
    }
    boolean structureCheck(currentNodeID) {
        // Get the structure list
        if(!currentNodeID) return false;
        var sL = nodeMap.pjsStructureList;
        var s = sL[currentNodeID];
        if(s){
            s.setTransparency(128);
            return true;
        }
        return false;
    }
    // If the current structure is a delivery location, add points,
    // if it is a fuel station reduce cash but increase fuel capacity
    void updateInfo(atStruct){
        if (atStruct.StructType != "fuel_stn" && !atStruct.visited) {
            levelCash += atStruct.Points;
            atStruct.visited = true;
            deliveriesLeft--;
            cashHUD.innerHTML = "$" + levelCash;
            parcelHUD.innerHTML = "x " + deliveriesLeft;
        } 
        else if (atStruct.StructType == "fuel_stn" && !refueled) {
            refueled = true;
            var fuelMissing = fuelGauge.denominator - fuelGauge.numerator;
            var totalFuelCost = fuelMissing * fuelCost;
            var enoughCash = (levelCash - totalFuelCost) >= 0 ? true : false;
            if (enoughCash) {
                levelCash -= totalFuelCost;
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
                    fuelGauge.numerator += ticksToFill;
                    needlePosition += ticksToFill * needleDelta;
                }
            }
            cashHUD.innerHTML = "$" + levelCash;
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
            }
        }

        if (!gameOver && edgeDelta > 0 && tickDelta >= deltaPerTick) {
            tickDelta -= deltaPerTick;
            consumeFuel();
            checkIfFuelEmpty();
        }
        // Draw the vehicle
        super.drawObject();
    }
    // Subtract the fraction from the fuel gauge and update the HUD
    void consumeFuel() {
        fuelGauge.numerator -= 1;
        if (needlePosition > -NEEDLE_RANGE) needlePosition -= needleDelta;
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
    void mouseDragged(int mx, int my, int button) {
        if (mapScreen && button == LEFT) {
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
            box.translate(_x, _y, layer.parent);
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
            if (destination.length > 0) driveToDestination();
        } else {
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

                if (shadowMapColorDictionary[c][0].vertex.equals(futurePosition)) {
                    destination.push(shadowMapColorDictionary[c][1]);
                    if (!flippedVertexX && !flippedVertexY) {
                        roadSelectedDictionary[c][0] += 1;
                    } else if (flippedVertexX || flippedVertexY) {
                        roadSelectedDictionary[c][1] += 1;
                    }
                    futurePosition = shadowMapColorDictionary[c][1].vertex;
                    currDestColorID.push(c);
                } else if (shadowMapColorDictionary[c][1].vertex.equals(futurePosition)) {
                    destination.push(shadowMapColorDictionary[c][0]);
                    if (!flippedVertexX && !flippedVertexY) {
                        roadSelectedDictionary[c][1] += 1;
                    } else if (flippedVertexX || flippedVertexY) {
                        roadSelectedDictionary[c][0] += 1;
                    }
                    futurePosition = shadowMapColorDictionary[c][0].vertex;
                    currDestColorID.push(c);
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
                    if (destination.length > 0) {
                        futurePosition = destination[destination.length - 1].vertex;
                    } else {
                        futurePosition = currentPosition;
                    }
                    currDestColorID.pop();
                }
            }
        }
    }
    void setStates() {
        addState(new State("Player", assetsFolder+"car.png"));
    }
    void stopVehicle() {
        stop();
        edgeDelta = 0;
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
    var currX = 0, currY = 0;
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
        text(fracText, vertical ? vertex1.x + 12 : ((vertex1.x + vertex2.x) * 0.5),
            horizontal ? vertex1.y - 32 : ((vertex1.y + vertex2.y) * 0.5));
        textAlign(LEFT);
        fill(126);
        if (DISPLAY_SHADOWMAP) image(shadowMap, 0, 0);
    }
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
        addState(new State("default",structureFolder+"depot.svg"));
    }
}
class Struct extends InputInteractor {
    var vertex, sBox, structObject;
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
        addState(new State("default",structureFolder+structObject.StructType+".svg"));
    }
    void draw(float v1x,float v1y,float v2x, float v2y){
        super.draw(v1x,v1y,v2x,v2y);
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
            hovering = true;
            setScale(0.7);
        } else if (hovering) {
            hovering = false;
            setScale(0.5);
        }
    }
}
/*
**  Debugging Classes. Remove at release.
 */
class StructDebug extends Struct{

    StructDebug(vert,structObject){
        super(vert,structObject);
    }
    void draw(float v1x,float v1y,float v2x, float v2y){
        pushMatrix();
        //scale(zoomLevel);
        if(structObject.StructType=="fuel_stn")
            stroke(0,255,0);
        else
            stroke(255,0,0);
        ellipse(vertex.x,vertex.y,8,8);
        popMatrix();
    }
}
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
