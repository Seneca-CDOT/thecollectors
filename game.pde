/* @pjs preload="assets/gas.png" */

final int screenWidth=960;
final int screenHeight=640;

float zoomLevel=1;
int arrowSpeed=10;
int dragSpeed=10;
//line width
strokeWeight(4);
debug=true;

void mouseOver() {
    canvasHasFocus = true;
}

void mouseOut() {
    canvasHasFocus = false;
}

void initialize() {
    var gen=new MapGenerator(0);
    addScreen("testing",new XMLLevel(screenWidth*2,screenHeight*2,new Map(gen.mapGraph,gen.structureList)));
	//addScreen("testing",new XMLLevel(screenWidth*2,screenHeight*2,new Map(0,0,"map.xml")));
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
        if(debug){

            for(index in mapIn.mapGraph.nodeDictionary){
                var x=mapIn.mapGraph.nodeDictionary[index].vertex.x;
                var y=mapIn.mapGraph.nodeDictionary[index].vertex.y;
                NodeDebug tmp = new NodeDebug(new Vertex(x,y),mapIn.mapGraph.nodeDictionary[index].flag);
                addInteractor(tmp);
            }
        }
		/* Boundaries not necessary at the moment. Leaving this here just in case
		addBoundary(new Boundary(0,height,width,height));
		addBoundary(new Boundary(width,height,width,0));
		addBoundary(new Boundary(width,0,0,0));
		addBoundary(new Boundary(0,0,0,height));
		*/
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
            }
            if(mouseScroll!=0){
                zoomLevel+= mouseScroll/10;
            }
            if(isKeyDown('+') || isKeyDown('='))
                zoomLevel+=1/3/10;
            if(isKeyDown('-'))
                zoomLevel-=1/3/10;
        }
        mouseScroll=0;
        keyCode=undefined;
    }
    void mouseDragged(int mx, int my, int button){
        ViewBox box=layer.parent.viewbox;
        int _x=0, _y=0;
        if(mx-pmouseX >0) _x-=dragSpeed;
        else if (mx-pmouseX < 0) _x+=dragSpeed;
        if(my-pmouseY <0) _y+=dragSpeed;
        else if (my-pmouseY>0) _y-=dragSpeed;
        box.translate(_x,_y,layer.parent);
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
        pushMatrix();
        //translate(vertex1.x,vertex1.y);
        scale(zoomLevel);
        stroke(0,0,255);
        line(vertex1.x, vertex1.y, vertex2.x, vertex2.y);
        popMatrix();
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
    void draw(float v1x,float v1y,float v2x, float v2y){
        pushMatrix();
        //translate(vertex.x,vertex.y);
        scale(zoomLevel);
        //translate(-vertex.x,-vertex.y);
        //setScale(zoomLevel);
        super.draw(v1x,v1y,v2x,v2y);
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
        scale(zoomLevel);
        if(flag)
            stroke(0,255,0);
        else
            stroke(255,0,0);
        ellipse(vertex.x,vertex.y,8,8);
        popMatrix();
    }
}
