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
        deliveriesLeft = 4;
        map = new Map(0,0,"tutorial.xml");
        renderMap(map);
        //overlayTutorialInterface();
    }
    // For the tutorial, we need to enable a custom overlay that shows the player
    // the parts of the game in a certain order and guides them through the gameplay.
    void overlayTutorialInterface() {
    }
    void generateMap() {
        deliveriesLeft = 2 * currentLevel + 2;
        var simpleMultiples = true;
        var map=new Map(deliveriesLeft,gameDifficulty);
        renderMap(map);
    }
    void renderMap(generatedMap) {
        mapScreen = true;
        addLevelLayer("Level", new MapLevel(this, generatedMap));
    }
    void draw() {
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
}

class MapLevel extends LevelLayer {
    var generatedMap = null;
    var r = 0, g = 0, b = 0;
    var shadowBounds = [];

    MapLevel(Level owner, map) {
        super(owner);
        shadowMap = null;
        shadowMapColorDictionary = {};
        roadSelectedDictionary = {};
        shadowMap = createGraphics(screenWidth * 2, screenHeight * 2, JAVA2D);
        generatedMap = map;
        setBackgroundColor(color(197, 233, 203));
        initializeRoads();
    }
    void zoom(float s) {
        if (xScale + s < 0.7) {
            setScale(0.7);
            zoomLevel = 1.3;
        } else if (xScale + s > 1.6) {
            setScale(1.6);
            zoomLevel = 0.4;
        } else {
            setScale(xScale + s);
            zoomLevel -= s;
        }
    }
    // Calculate the shadow road vertices
    void calculateShadowBounds(vertex1, vertex2) {
        var vFlippedX = (vertex1.x - vertex2.x) < 0 ? false : true;
        var vFlippedY = (vertex1.y - vertex2.y) < 0 ? false : true;
        if (vertex1.x - vertex2.x == 0 && !vFlippedY) {
            shadowBounds[0] = vertex1.x;
            shadowBounds[1] = vertex1.y + 17;
            shadowBounds[2] = vertex2.x;
            shadowBounds[3] = vertex2.y - 17;
        } else if (vertex1.x - vertex2.x == 0 && vFlippedY) {
            shadowBounds[0] = vertex1.x;
            shadowBounds[1] = vertex2.y + 17;
            shadowBounds[2] = vertex2.x;
            shadowBounds[3] = vertex1.y - 17;
        }
        if (vertex1.y - vertex2.y == 0 && !vFlippedX) {
            shadowBounds[0] = vertex1.x + 17;
            shadowBounds[1] = vertex1.y;
            shadowBounds[2] = vertex2.x - 17;
            shadowBounds[3] = vertex2.y;
        } else if (vertex1.y - vertex2.y == 0 && vFlippedX) {
            shadowBounds[0] = vertex2.x + 17;
            shadowBounds[1] = vertex1.y;
            shadowBounds[2] = vertex1.x - 17;
            shadowBounds[3] = vertex2.y;
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
                calculateShadowBounds(primaryNode.vertex, connectedNode.vertex);
                shadowMap.line(shadowBounds[0], shadowBounds[1], shadowBounds[2], shadowBounds[3]);

                // Store the nodes that make up the edge using its color as the ID
                var colorID = hex(shadowColor);
                shadowMapColorDictionary[colorID] = [];
                shadowMapColorDictionary[colorID].push(primaryNode);
                shadowMapColorDictionary[colorID].push(connectedNode);

                // Create and add the road segment to the level
                Road roadSegment = new Road(colorID, primaryNode.vertex, connectedNode.vertex, fraction);
                addInteractor(roadSegment);

                // Initialize road selected values
                roadSelectedDictionary[colorID] = [];
                roadSelectedDictionary[colorID][0] = 0;
                roadSelectedDictionary[colorID][1] = 0;

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
        shadowBounds = [];
        initializePlayer();
        if(debugging){
            var allNodes=generatedMap.mapGraph.nodeDictionary;
            for(index in allNodes){
                NodeDebug tmp = new NodeDebug(allNodes[index].vertex, index);
                addInteractor(tmp);
            }
        }
    }
    void initializeStructures(fuelCost) {
		var structureListLength = generatedMap.structureList.length;
		for(var i = 0; i < structureListLength; i++) {
			var structObject = generatedMap.structureList[i];
			var vert = generatedMap.mapGraph.findNodeArray(structObject.nodeID).vertex;
            if (debugging)
                StructDebug structure = new StructDebug(vert,structObject);
            else
                Struct structure = new Struct(vert,structObject, generatedMap.fuel.denominator, fuelCost);
            addInputInteractor(structure);
		}
    }
    void initializePlayer() {
        player = new Driver(generatedMap);
        addPlayer(player);
        var depot = new Depot(generatedMap.startPoint.clone());
        addInteractor(depot);
        initializeStructures(player.fuelCost);
    }
}
