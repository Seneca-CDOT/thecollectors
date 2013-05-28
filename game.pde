/* @pjs preload="assets/gas.png" */

final int screenWidth=960;
final int screenHeight=640;

float zoomLevel=0.5;
//line width
strokeWeight(4);


void initialize() {
	addScreen("testing",new XMLLevel(screenWidth,screenHeight,new Map("map.xml")));
}
class XMLLevel extends Level{
	XMLLevel(float levelWidth,float levelHeight,var mapIn){
		super(levelWidth,levelHeight)
		addLevelLayer("",new XMLLevelLayer(this,mapIn));
	}
}
class XMLLevelLayer extends LevelLayer{
	XMLLevelLayer(Level owner, mapIn){
		super(owner);
		color bgcolor=color(243,233,178);
		setBackgroundColor(bgcolor);
		int ln=mapIn.edgeBuffer.getLength();
		for (int i=0;i<ln;i++){
			var road=mapIn.edgeBuffer.getEdge(i);
	
			var vert1=mapIn.vertexBuffer.getVertex(road.vertexOneID);
			var vert2=mapIn.vertexBuffer.getVertex(road.vertexTwoID);
			Road temp= new Road(vert1,vert2);
			addInteractor(temp);
		}
		ln=mapIn.StructureBuffer.getLength();
		for(int i=0;i<ln;i++){
			var struct=mapIn.StructureBuffer.getStructure(i);
			var vert=mapIn.vertexBuffer.getVertex(struct.vertexID);
			Struct temp= new Struct(vert);
			addInteractor(temp);
		}
		Driver p1=new Driver();
		addPlayer(p1);
	}
}
class Driver extends Player{
	Driver(){
		super("Driver");
		//setStates();
		handleKey('+');
		handleKey('-');
	}
	void handleInput(){
		
		//console.log(keyDown[65]);
		if(mouseScroll!=0){
			zoomLevel+= mouseScroll/10;
			mouseScroll=0;
		}
		if(isKeyDown('+'))	
			zoomLevel+=1/3/10;
		if(isKeyDown('-'))
			zoomLevel-=1/3/10;
	}
	void mouseDragged(int mx, int my, int button){
		//cahnge view port here
		//console.log(mx+" : " + my + "button: "+button); //37 left - 39 right
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
		//translate(-vertex1.x,-vertex1.y);
		//setScale(zoomLevel);
		//var v1=vertex1.scale(zoomLevel);
		//var v2=vertex2.scale(zoomLevel);
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