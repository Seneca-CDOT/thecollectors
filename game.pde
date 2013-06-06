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
            addScreen("testing",new XMLLevel(screenWidth*2,screenHeight*2,new Map(0,0,"map.xml")));
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

void initialize() {
    clearScreens(); // reset the screen
    /*  title sequence/ main menu
    addScreen("Title Screen", new TitleScreen(screenWidth, screenHeight));
    setActiveScreen("Title Screen"); // useful for when more screens are added
    */
    addScreen("testing",new XMLLevel(screenWidth*2,screenHeight*2,new Map(0,0,"map.xml")));
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
		color bgcolor=color(243,233,178);
		setBackgroundColor(bgcolor);
		var edgeList=mapIn.getEdgeList();
		
		for (index in edgeList){
			var vert1=mapIn.mapGraph.findNodeArray(index).vertex;
			for (var i = edgeList[index].length - 1; i >= 0; i--) {
				var vert2=mapIn.mapGraph.findNodeArray(edgeList[index][i]).vertex;
				Road temp= new Road(vert1,vert2);
				addInteractor(temp);
			};
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
		/* Boundaries not necessary at the moment. Leaving this here just in case
		addBoundary(new Boundary(0,height,width,height));
		addBoundary(new Boundary(width,height,width,0));
		addBoundary(new Boundary(width,0,0,0));
		addBoundary(new Boundary(0,0,0,height));
		*/
        mapIn.exportToXML();
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
                keyCode=undefined;
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
        }
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
        pmouseX = mx;
        pmouseY = my;
    }
}
class Road extends Interactor{
    var vertex1;
    var vertex2;
    Road(vert1,vert2){
        super("Road");
        vertex1=vert1;
        vertex2=vert2;
    }
    void draw(float v1x,float v1y,float v2x, float v2y){
        line(vertex1.x, vertex1.y, vertex2.x, vertex2.y);
    }
}
class Struct extends Interactor{
    var vertex;
    Struct(vert){
        super("Desc");
        setPosition(vert.x,vert.y);
        vertex=vert;
        setStates();
    }
    void setStates(){
        addState(new State("default","assets/gas.png"));
    }
}
