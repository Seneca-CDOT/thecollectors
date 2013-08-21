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
