/* @pjs preload="assets/gas.png,
                 assets/car.png,
                 assets/titleScreenTest.jpg";
 */

final int screenWidth=960;
final int screenHeight=640;

PGraphics shadowMap = null;
var shadowMapColorDictionary;
var roadSelectedDictionary;
float VEHICLE_SPEED = 1.5;
float zoomLevel=1;
int arrowSpeed=10;
int gameDifficulty = 0;
//line width
strokeWeight(4);
var GEN_TUTORIAL = true;
var DISPLAY_SHADOWMAP = false;

/*debugging tools*/
var mapType="gen"; //change between "xml" or "gen"
var showMenus=false;

boolean debugging=true;


void mouseOver() {
    canvasHasFocus = true;
}

void mouseOut() {
    canvasHasFocus = false;
}

void loadDifficulty(diffVal, gameMode) {
    gameDifficulty = diffVal;

    if (gameMode == "Campaign") {
        if (diffVal == 1) {
            // Change to correct screen later
            addScreen("testing",new XMLLevel(screenWidth*2,screenHeight*2,new Map("map.xml")));
            addScreen("testing", new CampaignMap(screenWidth * 2, screenHeight * 2));
            setActiveScreen("testing");
        } else if (diffVal == 2) {
            // Change to correct screen later
            addScreen("testing",new XMLLevel(screenWidth*2,screenHeight*2,new Map("map.xml")));
            setActiveScreen("testing");
        } else if (diffVal == 3) {
            // Change to correct screen later
            addScreen("testing",new XMLLevel(screenWidth*2,screenHeight*2,new Map("map.xml")));
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

void initialize() {
    clearScreens(); // reset the screen
    if(showMenus){
        addScreen("Title Screen", new TitleScreen(screenWidth, screenHeight));
        setActiveScreen("Title Screen"); // useful for when more screens are added
    }
    if(mapType=="xml"){
        /*addScreen("XMLLevel",new XMLLevel(screenWidth*2,screenHeight*2,new Map("map.xml")));
        if(!showMenus)
            setActiveScreen("XMLLevel");
            */
        addScreen("testing", new CampaignMap(screenWidth * 2, screenHeight * 2));
    }
    else{
        addScreen("testing",new XMLLevel(screenWidth*2,screenHeight*2,new Map()));
    }
}

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
            new Sprite("assets/titleScreenTest.jpg"), 0, 0, screenWidth, screenHeight));
    }
}

class CampaignMap extends Level {
    var denominator = 0;

    CampaignMap(float mWidth, float mHeight) {
        super(mWidth, mHeight);
        setViewBox(0, 0, screenWidth, screenHeight);

        if (GEN_TUTORIAL || (gameDifficulty == 1 && currentLevel == 1)) {
            generateTutorial();
        } else {
            generateMap();
        }
    }
    // Generate the tutorial map. The map is static except for the denominator, and is
    // imported from an XML file.
    void generateTutorial() {
        var map = null;
        map = new Map(null, null, "tutorial.xml");
        renderMap(map);
        //overlayTutorialInterface();
    }
    // For the tutorial, we need to enable a custom overlay that shows the player
    // the parts of the game in a certain order and guides them through the gameplay.
    void overlayTutorialInterface() {
    }
    void generateMap() {
        var map = null;
        var numDeliveries = 2 * currentLevel + 2;
        var simpleMultiples = true;
/*
        map = new MapGenerator(gameDifficulty);
            //numDeliveries = int,fractionModChance = float,simpleMultiples = bool
        denominator = 0; // extract the denominator to pass back into future map generations

        renderMap(map);
*/      renderMap(null);
    }
    void renderMap(generatedMap) {
        addLevelLayer("Level", new MapLevel(this, generatedMap));
    }
}

class MapLevel extends LevelLayer {
    var generatedMap = null;
    var r = 0, g = 0, b = 0;

    MapLevel(Level owner, map) {
        super(owner);
        shadowMap = null;
        shadowMapColorDictionary = {};
        roadSelectedDictionary = {};
        shadowMap = createGraphics(screenWidth * 2, screenHeight * 2, JAVA2D);
        generatedMap = map;
		setBackgroundColor(color(243, 233, 178)); // for testing, replace with texture for final product
        initializeRoads();
    }
    void zoom(float s) {
        if (xScale + s < 0) {
            setScale(0);
        } else {
            setScale(xScale + s);
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
                shadowMap.line(primaryNode.vertex.x, primaryNode.vertex.y, connectedNode.vertex.x,
                        connectedNode.vertex.y);

                // Store the coordinates that make up the edge using its color as the ID
                var colorID = hex(shadowColor);
                shadowMapColorDictionary[colorID] = [];
                shadowMapColorDictionary[colorID].push(primaryNode.vertex);
                shadowMapColorDictionary[colorID].push(connectedNode.vertex);

                // Create and add the road segment to the level
                Road roadSegment = new Road(colorID, primaryNode.vertex, connectedNode.vertex, fraction);
                addInteractor(roadSegment);

                // Initialize road selection
                roadSelectedDictionary[colorID] = false;

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
        initializeStructures();
    }
    void initializeStructures() {
		var structureListLength = generatedMap.structureList.length;
		for(var i = 0; i < structureListLength; i++) {
			var structObject = generatedMap.structureList[i];
			var vert = generatedMap.mapGraph.findNodeArray(structObject.nodeID).vertex;
			Struct structure = new Struct(vert);
			addInteractor(structure);
		}
        initializePlayer();
    }
    void initializePlayer() {
        playerAvatar = new Driver(generatedMap.startPoint);
        addPlayer(playerAvatar);
    }
}

class XMLLevel extends Level{
    XMLLevel(float levelWidth,float levelHeight,var mapIn){
        super(levelWidth,levelHeight)
            addLevelLayer("",new XMLLevelLayer(this,mapIn));
        setViewBox(0,0,screenHeight, screenHeight);
    }
}
class XMLLevelLayer extends LevelLayer{
	XMLLevelLayer(Level owner, mapIn){
		super(owner);
        debug=debugging;

		color bgcolor=color(243,233,178);
		setBackgroundColor(bgcolor);
		var edgeList=mapIn.getEdgeList();
		for (index in edgeList){
			var vert1=mapIn.mapGraph.findNodeArray(index).vertex;
			for (var i = edgeList[index].length - 1; i >= 0; i--) {
				var vert2=mapIn.mapGraph.findNodeArray(edgeList[index][i]).vertex;
				Road temp= new Road(i, vert1,vert2, new Fraction(1, 7));
				addInteractor(temp);
			}
		}
		ln=mapIn.structureList.length;
		for(int i=0;i<ln;i++){
			var struct=mapIn.structureList[i];
			var vert=mapIn.mapGraph.findNodeArray(struct.nodeID).vertex;
			Struct temp= new Struct(vert);
			addInteractor(temp);
		}
		Driver driver=new Driver(mapIn.startPoint);
		addPlayer(driver);
        if(debug){
            for(index in mapIn.mapGraph.nodeDictionary){
                var x=mapIn.mapGraph.nodeDictionary[index].vertex.x;
                var y=mapIn.mapGraph.nodeDictionary[index].vertex.y;
                NodeDebug tmp = new NodeDebug(new Vertex(x,y),mapIn.mapGraph.nodeDictionary[index]);//mapIn.mapGraph.nodeDictionary[index].flag);
                addInteractor(tmp);
            }
        }
		/* Boundaries not necessary at the moment. Leaving this here just in case
		addBoundary(new Boundary(0,height,width,height));
		addBoundary(new Boundary(width,height,width,0));
		addBoundary(new Boundary(width,0,0,0));
		addBoundary(new Boundary(0,0,0,height));
		*/
        //console.log(mapIn.exportToXML());         doesnt work with rng maps yet
	}
    void zoom(float s){
        if(xScale+s < 0)
            setScale(0);
        else
            setScale(xScale+s);
    }
}
class Driver extends Player{
    var currentPosition, previousPosition, destination, futurePosition, currDest;
    var edgeDelta, roadDeltaX = 0, roadDeltaY = 0, direction = 0;
    var currDestColorID;
    Driver(startPoint) {
        super("Driver");
        setStates();
        handleKey('+');
        handleKey('='); // For the =/+ combination key
        handleKey('-');
        handleKey(' ');
        currentPosition = startPoint;
        futurePosition = startPoint; // for multi-road selection
        setPosition(currentPosition.x, currentPosition.y);
        previousPosition = new Vertex(getPrevX(), getPrevY());
        destination = [];
        currDest = null;
        currDestColorID = [];
        setScale(0.8);
    }
    void handleInput(){
        if (canvasHasFocus) {
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
    void driveToDestination() {
        var impulseX = 0, impulseY = 0;

        // Get the current destination from the destination list
        currDest = destination.shift();
        roadDeltaX = currDest.x - currentPosition.x;
        roadDeltaY = currDest.y - currentPosition.y;

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
        edgeDelta = distance(previousPosition, currDest);
    }
    void drawObject() {
        currentPosition.x = getX();
        currentPosition.y = getY();
        var vehicleDelta = distance(currentPosition, previousPosition);

        /* If the vehicle has travelled a greater distance than the distance from its
         * starting location to its destination, stop the vehicle and re-position it
         * on the destination
         */
        if (edgeDelta > 0 && vehicleDelta > 0 && vehicleDelta > edgeDelta) {
            stopVehicle();
            setPosition(currDest.x, currDest.y);
            previousPosition.x = currentPosition.x = getX();
            previousPosition.y = currentPosition.y = getY();

            // Reset deltas
            roadDeltaX = 0;
            roadDeltaY = 0;

            // Keep driving as long as we haven't run out of destinations
            if (destination.length != 0) {
                driveToDestination();
            }
            // De-select the road we finished driving over
            roadSelectedDictionary[currDestColorID.shift()] = false;
        }
        // Draw the vehicle
        super.drawObject();
    }
    void mouseDragged(int mx, int my, int button) {
        if (button == LEFT) {
            ViewBox box = layer.parent.viewbox;
            int _x = 0, _y = 0;
            int deltaX = mx - pmouseX;
            int deltaY = my - pmouseY;
            if (deltaX > 0) _x -= Math.abs(deltaX);
            else if (deltaX < 0) _x += Math.abs(deltaX);
            if (deltaY < 0) _y += Math.abs(deltaY);
            else if (deltaY > 0) _y -= Math.abs(deltaY);
            box.translate(_x, _y, layer.parent);
        }
    }
    void mouseClicked(int mx, int my, int button) {
        var vBox = getBoundingBox();
        var vBoxDeltaX = Math.abs(vBox[0] - vBox[4]) * 0.5;
        var vBoxDeltaY = Math.abs(vBox[1] - vBox[5]) * 0.5;

        // Did we click on the vehicle? If not, check if we clicked on a road
        if (mx >= getX() - vBoxDeltaX && mx <= getX() + vBoxDeltaX &&
                my >= getY() - vBoxDeltaY && my <= getY() + vBoxDeltaY) {
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
                if (shadowMapColorDictionary[c][0].equals(futurePosition)) {
                    destination.push(shadowMapColorDictionary[c][1]);
                    roadSelectedDictionary[c] = true;
                    futurePosition = shadowMapColorDictionary[c][1];
                    currDestColorID.push(c);
                } else if (shadowMapColorDictionary[c][1].equals(futurePosition)) {
                    destination.push(shadowMapColorDictionary[c][0]);
                    roadSelectedDictionary[c] = true;
                    futurePosition = shadowMapColorDictionary[c][0];
                    currDestColorID.push(c);
                } else {
                    roadSelectedDictionary[c] = false;
                    console.log("Registered click on invalid road");
                }
            } else if (shadowMapColorDictionary[c] != null && button == RIGHT) {
                if ((shadowMapColorDictionary[c][0].equals(futurePosition) ||
                        shadowMapColorDictionary[c][1].equals(futurePosition)) &&
                        destination.length > 0) {
                    roadSelectedDictionary[c] = false;
                    destination.pop();
                    if (destination.length > 0) {
                        futurePosition = destination[destination.length - 1];
                    } else {
                        futurePosition = currentPosition;
                    }
                    currDestColorID.pop();
                }
            }
        }
    }
    void setStates() {
        addState(new State("Player", "assets/car.png"));
    }
    void stopVehicle() {
        stop();
    }
    void mouseClicked(int mx, int my, int button){
        if(layer.debug){
            println("x:"+mx+" || "+"y:"+my);
        }   
    }
}
class Road extends Interactor {
    var vertex1;
    var vertex2;

    Road(vert1, vert2) {
    PFont fracFont;
    var fracText = "";
    var currX = 0, currY = 0;
    var roadBounds = [];
    var cID;
    Road(id, vert1, vert2, frac) {
        super("Road");
        vertex1 = vert1;
        vertex2 = vert2;
        fracFont = loadFont("EurekaMonoCond-Bold.ttf");
        textFont(fracFont, 14);
        textLeading(9);
        fracText = frac.numerator.toString() + "\n--\n" + frac.denominator.toString();
        // Associate the road segment with its shadowMap road's hexadecimal colour code
        cID = id;
        calculateBounds();
    }
    // Calculate the box that acts as the highlight for the road segment
    void calculateBounds() {
        var vFlippedX = (vertex1.x - vertex2.x) < 0 ? false : true;
        var vFlippedY = (vertex1.y - vertex2.y) < 0 ? false : true;
        if (vertex1.x - vertex2.x == 0 && !vFlippedY) {
            roadBounds[0] = vertex1.x - 12;
            roadBounds[1] = vertex1.y + 11;
            roadBounds[2] = vertex2.x + 12;
            roadBounds[3] = vertex2.y - 11;
        } else if (vertex1.x - vertex2.x == 0 && vFlippedY) {
            roadBounds[0] = vertex1.x - 12;
            roadBounds[1] = vertex2.y + 11;
            roadBounds[2] = vertex2.x + 12;
            roadBounds[3] = vertex1.y - 11;
        }
        if (vertex1.y - vertex2.y == 0 && !vFlippedX) {
            roadBounds[0] = vertex1.x + 11;
            roadBounds[1] = vertex1.y - 12;
            roadBounds[2] = vertex2.x - 11;
            roadBounds[3] = vertex2.y + 12;
        } else if (vertex1.y - vertex2.y == 0 && vFlippedX) {
            roadBounds[0] = vertex2.x + 11;
            roadBounds[1] = vertex1.y - 12;
            roadBounds[2] = vertex1.x - 11;
            roadBounds[3] = vertex2.y + 12;
        }
    }
    void draw(float v1x,float v1y,float v2x, float v2y){
        if(debugging)
            stroke(0,0,255);
		else
            stroke(0,0,0);
        line(vertex1.x, vertex1.y, vertex2.x, vertex2.y);

        // If the road has been selected or the mouse is within the road bounds,
        // draw the road highlight
        if (roadSelectedDictionary[cID] == true || (pmouseX >= roadBounds[0] && pmouseX <= roadBounds[2] &&
                pmouseY >= roadBounds[1] && pmouseY <= roadBounds[3])) {
            fill(173, 216, 230, 70);
            noStroke();
            rect(roadBounds[0], roadBounds[1], roadBounds[2] - roadBounds[0],
                    roadBounds[3] - roadBounds[1]);
            stroke(0);
        }

        // Render the fraction text next to the road segment
        fill(126);
        text(fracText, (vertex1.x - vertex2.x) == 0 ? vertex1.x + 5 : ((vertex1.x + vertex2.x) * 0.5),
            (vertex1.y - vertex2.y) == 0 ? vertex1.y - 23 : ((vertex1.y + vertex2.y) * 0.5));
        if (DISPLAY_SHADOWMAP) image(shadowMap, 0, 0);
    }
}
class Struct extends Interactor {
    var vertex;
    Struct(vert) {
        super("Desc");
        setPosition(vert.x, vert.y);
        vertex = vert;
        setStates();
    }
    void setStates() {
        addState(new State("default","assets/gas.png"));
    }
    void draw(float v1x,float v1y,float v2x, float v2y){
        super.draw(v1x,v1y,v2x,v2y);
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
        scale(zoomLevel);
        fill(0,0,0);
        if(flag)
            stroke(0,255,0);
        else
            stroke(255,0,0);
        //text(flag.id+":"+flag.connectionsLength, vertex.x-4, vertex.y-2);
        ellipse(vertex.x,vertex.y,8,8);
        popMatrix();
    }
}
