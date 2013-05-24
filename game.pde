final int screenWidth=960;
final int screenHeight=640;

void initialize() {
	addScreen("level1",new MyLevel(screenWidth,screenHeight));
}

class MyLevel extends Level{
	MyLevel(float levelWidth,float levelHeight){
		super(levelWidth, levelHeight);
		addLevelLayer("layer1",new MyLevelLayer(this));
	}
}
class MyLevelLayer extends LevelLayer{
	MyLevelLayer(Level owner){
		super(owner);
		color blueishColor=color(0,130,255);
		setBackgroundColor(blueishColor);
	}
}