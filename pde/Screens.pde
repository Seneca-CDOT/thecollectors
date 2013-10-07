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
    var type;
    int x;
    VehicleOption(var _type){
        super("Vehicle Option");
        type=_type;
        x = (type-1)*(150+38)+19+(150/2);
        setPosition(x,300);
        setStates();
    }
    void setStates(){
        addState(new State("default",assetsFolder+"vehicles/"+vehicleTypes[this.type][1]));
    }
    void mouseClicked(int mx, int my, int button){
        if(over(mx,my)){
            //do some buying stuff
        }
    }
}
class InterScreen extends Level {
    InterScreen(int sWidth, int sHeight){
        super(sWidth, sHeight);
        addLevelLayer("Inter Screen Layer", new InterScreenLayer(this));
    }
}
class InterScreenLayer extends LevelLayer {
    InterScreenLayer(Level owner){
        super(owner);
        setBackgroundColor(color(197, 233, 203));
        addInputInteractor(new VehicleOption(1));
        addInputInteractor(new VehicleOption(2));
        addInputInteractor(new VehicleOption(3));
        addInputInteractor(new VehicleOption(4));
        addInputInteractor(new VehicleOption(5));

    }
}
