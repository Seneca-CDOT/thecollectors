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
        deliveriesLeft = 3;
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
/*    void draw() {
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
*/
}
