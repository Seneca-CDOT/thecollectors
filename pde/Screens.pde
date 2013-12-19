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
