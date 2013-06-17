/* @pjs preload="assets/gas.png,
                 assets/titleScreenTest.jpg";
 */

final int screenWidth=960;
final int screenHeight=640;

float zoomLevel=1;
int arrowSpeed=10;
int gameDifficulty = 0;
//line width
strokeWeight(4);

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
        addScreen("XMLLevel",new XMLLevel(screenWidth*2,screenHeight*2,new Map("map.xml")));
        if(!showMenus)
            setActiveScreen("XMLLevel");
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

        if (gameDifficulty == 1 && currentLevel == 1) {
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

    MapLevel(Level owner, map) {
        super(owner);
        generatedMap = map;
		setBackgroundColor(color(0, 255, 0)); // for testing, replace with texture for final product
        initializeRoads();
    }
    void initializeRoads() {
        var edgeList = generatedMap.getEdgeList();
        for (index in edgeList) {
            var vert1 = generatedMap.mapGraph.findNodeArray(index).vertex;
            for (var i = edgeList[index].length - 1; i >= 0; i--) {
                var vert2 = generatedMap.mapGraph.findNodeArray(edgeList[index][i]).vertex;
                Road roadSegment = new Road(vert1, vert2);
                addInteractor(roadSegment);
            }
        }
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
		Driver playerAvatar = new Driver();
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
				Road temp= new Road(vert1,vert2);
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
		Driver driver=new Driver();
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
    Driver(){
        super("Driver");
        handleKey('+');
        handleKey('='); // For the =/+ combination key
        handleKey('-');
        handleKey(' ');
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
    void mouseDragged(int mx, int my, int button) {
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
    void mouseClicked(int mx, int my) {
        
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
        super("Road");
        vertex1=vert1;
        vertex2=vert2;
    }
    void draw(float v1x,float v1y,float v2x, float v2y){
        if(debugging)
            stroke(0,0,255);
		else
            stroke(0,0,0);
        line(vertex1.x, vertex1.y, vertex2.x, vertex2.y);
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
