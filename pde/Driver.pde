/**
 *  Controls the car. Handles user input.
 */

class Driver extends Player{
    var currentPosition, previousPosition, destination, currDest;
    var edgeDelta = 0, roadDeltaX = 0, roadDeltaY = 0, direction = 0;
    var currDestColorID, nodeMap, fuelGauge, fuelCost;
    var destinationWeight, deltaPerTick, tickDelta = 0, previousVehicleDelta = 0;
    var fuelGaugeHUD, fuelNeedleHUD, cashHUD, needlePosition = 0, needleDelta = 0;
    Driver(map) {
        super("Driver");
        setStates();
        handleKey('+');
        handleKey('='); // For the =/+ combination key
        handleKey('-');
        handleKey(' ');
        nodeMap = map;
        currentPosition = nodeMap.startPoint.clone();
        futurePosition = currentPosition; // for multi-road selection
        setPosition(currentPosition.x, currentPosition.y);
        previousPosition = new Vertex(getPrevX(), getPrevY());
        destination = [];
        destinationWeight = null;
        currDest = null;
        currDestColorID = [];
        driveFlag = false;
        fuelGauge = new Fraction(nodeMap.fuel.numerator, nodeMap.fuel.denominator);
        fuelGaugeHUD = document.getElementById("fuelElement2");
        fuelGaugeHUD.innerHTML = fuelGauge.numerator.toString();
        fuelGaugeHUD.innerHTML += "<br /><hr />";
        fuelGaugeHUD.innerHTML += fuelGauge.denominator.toString();
        needleDelta = NEEDLE_RANGE / fuelGauge.denominator;
        fuelNeedleHUD = document.getElementById("fuelNeedleDiv");
        cashHUD = document.getElementById("cashElement");
        cashHUD.innerHTML = "$" + levelCash;
        parcelHUD = document.getElementById("parcelElement");
        parcelHUD.innerHTML = "x " + deliveriesLeft;
        var fuelCostWeight = 1.0 - (0.6 - gameDifficulty * 0.2);
        fuelCost = Math.floor(StructureValues.fuel_stn * fuelCostWeight / fuelGauge.denominator);
        setScale(0.8);
    }
    void handleInput(){
        if (canvasHasFocus && mapScreen) {
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
                if (keyCode==ENTER) {
                    advanceTutorial();
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
    void mouseMoved(int mx, int my){
        canvasHasFocus=true;
    }
    void driveToDestination() {

        var impulseX = 0, impulseY = 0;

        refueled = false;
        // Get the current destination from the destination list
        currDest = destination.shift();
        roadDeltaX = currDest.vertex.x - currentPosition.x;
        roadDeltaY = currDest.vertex.y - currentPosition.y;

        // Set the vehicle direction and speed
        if (roadDeltaX != 0 && !roadDeltaY) {
            if (roadDeltaX > 0) {
                direction = HALF_PI;
                impulseX = VEHICLE_SPEED;
            } else if (roadDeltaX < 0) {
                direction = -HALF_PI;
                impulseX = -VEHICLE_SPEED;
            }
        }
        if (roadDeltaY != 0 && !roadDeltaX) {
            if (roadDeltaY > 0) {
                direction = PI;
                impulseY = VEHICLE_SPEED;
            } else if (roadDeltaY < 0) {
                direction = 0;
                impulseY = -VEHICLE_SPEED;
            }
        }

        setRotation(direction);
        setImpulse(impulseX, impulseY);
        edgeDelta = distance(previousPosition, currDest.vertex);

        // Get the connection weight (fraction) between the start
        // node and the destination node
        var idx = nodeMap.mapGraph.vertexExists(previousPosition);
        var startNode = nodeMap.mapGraph.nodeDictionary[idx];
        destinationWeight = startNode.connections[currDest.id];

        if(structureCheck(startNode.id))
            nodeMap.pjsStructureList[startNode.id].setTransparency(255);
        // Calculate the distance that the vehicle travels
        // across the current edge on one "tick" of fuel
        deltaPerTick = edgeDelta / destinationWeight.numerator;

        driveFlag = true;
    }
    boolean structureCheck(currentNodeID) {
        // Get the structure list
        if(!currentNodeID) return false;
        var sL = nodeMap.pjsStructureList;
        var s = sL[currentNodeID];
        if(s){
            s.setTransparency(128);
            return true;
        }
        return false;
    }
    // If the current structure is a delivery location, add points,
    // if it is a fuel station reduce cash but increase fuel capacity
    void updateInfo(atStruct){
        if (atStruct.StructType != "fuel_stn" && !atStruct.visited) {
            levelCash += atStruct.Points;
            atStruct.visited = true;
            deliveriesLeft--;
            cashHUD.innerHTML = "$" + levelCash;
            parcelHUD.innerHTML = "x " + deliveriesLeft;
        } 
        else if (atStruct.StructType == "fuel_stn" && !refueled) {
            refueled = true;
            var fuelMissing = fuelGauge.denominator - fuelGauge.numerator;
            var totalFuelCost = fuelMissing * fuelCost;
            var enoughCash = (levelCash - totalFuelCost) >= 0 ? true : false;
            if (enoughCash) {
                levelCash -= totalFuelCost;
                fuelGauge.numerator += fuelMissing;
                needlePosition += fuelMissing * needleDelta;
            } else {
                var total = 0;
                var ticksToFill = 0;
                var keepFilling = true;
                for (var i = 1; i <= fuelMissing && keepFilling; i++) {
                    total += fuelCost;
                    if (total > levelCash) {
                        keepFilling = false;
                        ticksToFill = i - 1;
                        total = ticksToFill * fuelCost;
                    }
                }
                if (ticksToFill) {
                    levelCash -= total;
                    fuelGauge.numerator += ticksToFill;
                    needlePosition += ticksToFill * needleDelta;
                }
            }
            cashHUD.innerHTML = "$" + levelCash;
            var fuelLevel = fuelGauge.evaluate();
            if (fuelLevel <= 0.2) {
                fuelGaugeHUD.style.cssText = "color:red";
            } else if (fuelLevel <= 0.5) {
                fuelGaugeHUD.style.cssText = "color:#ff6600";
            } else {
                fuelGaugeHUD.style.cssText = "color:white";
            }
            fuelGaugeHUD.innerHTML = fuelGauge.numerator.toString();
            fuelGaugeHUD.innerHTML += "<br /><hr />";
            fuelGaugeHUD.innerHTML += fuelGauge.denominator.toString();
            fuelNeedleHUD.style.cssText = "transform:rotate("+ needlePosition +"deg);";
        }
    }
    void drawObject() {
        currentPosition.x = getX();
        currentPosition.y = getY();
        var vehicleDelta = distance(currentPosition, previousPosition);
        if (!gameOver && vehicleDelta > 0) {
            tickDelta += vehicleDelta - previousVehicleDelta;
        }
        previousVehicleDelta = vehicleDelta;

        /* If the vehicle has travelled a greater distance than the distance from its
         * starting location to its destination, stop the vehicle and re-position it
         * on the destination
         */
        if (edgeDelta > 0 && vehicleDelta > 0 && vehicleDelta > edgeDelta) {
            stopVehicle();

            // De-select the road we finished driving over
            var index, delta;
            if (currDest.vertex.x - previousPosition.x == 0) {
                delta = currDest.vertex.y - previousPosition.y;
                index = delta < 0 ? 1 : 0;
            } else if (currDest.vertex.y - previousPosition.y == 0) {
                delta = currDest.vertex.x - previousPosition.x;
                index = delta < 0 ? 1 : 0;
            }
            roadSelectedDictionary[currDestColorID.shift()][index] -= 1;

            setPosition(currDest.vertex.x, currDest.vertex.y);
            previousPosition.x = currentPosition.x = getX();
            previousPosition.y = currentPosition.y = getY();

            // Reset deltas
            roadDeltaX = 0;
            roadDeltaY = 0;
            tickDelta = previousVehicleDelta = 0;

            consumeFuel();

            // Check if we've driven over a structure
            if(structureCheck(currDest.id)){
                updateInfo(nodeMap.pjsStructureList[currDest.id].structObject);
            }

            checkIfFuelEmpty();

            // Keep driving as long as we haven't run out of destinations
            if (!gameOver && destination.length != 0 && deliveriesLeft > 0) {
                driveToDestination();
            } else {
                driveFlag = false;
            }
        }

        if (!gameOver && edgeDelta > 0 && tickDelta >= deltaPerTick) {
            tickDelta -= deltaPerTick;
            consumeFuel();
            checkIfFuelEmpty();
        }
        // Draw the vehicle
        super.drawObject();
    }
    // Subtract the fraction from the fuel gauge and update the HUD
    void consumeFuel() {
        fuelGauge.numerator -= 1;
        if (needlePosition > -NEEDLE_RANGE) needlePosition -= needleDelta;
        var fuelLevel = fuelGauge.evaluate();
        if (fuelLevel <= 0.2) {
            fuelGaugeHUD.style.cssText = "color:red";
        } else if (fuelLevel <= 0.5) {
            fuelGaugeHUD.style.cssText = "color:#ff6600";
        } else {
            fuelGaugeHUD.style.cssText = "color:white";
        }
        fuelGaugeHUD.innerHTML = fuelGauge.numerator.toString();
        fuelGaugeHUD.innerHTML += "<br /><hr />";
        fuelGaugeHUD.innerHTML += fuelGauge.denominator.toString();
        fuelNeedleHUD.style.cssText = "transform:rotate("+ needlePosition +"deg);";
    }
    // If we're out of fuel and all deliveries have not been completed,
    // the game is over
    void checkIfFuelEmpty() {
        if (fuelGauge.numerator <= 0) {
            gameOver = true;
            levelCash = 0;
            cashHUD.innerHTML = "$" + levelCash;
            vehicleDelta = 0;
            stopVehicle();
        }
    }
    void mouseDragged(int mx, int my, int button) {
        if (mapScreen && button == LEFT) {
            ViewBox box = layer.parent.viewbox;
            int _x = 0, _y = 0;
            int deltaX = mx - pmouseX;
            int deltaY = my - pmouseY;
            deltaX = deltaX * zoomLevel;
            deltaY = deltaY * zoomLevel;
            if (deltaX < 0) {
                deltaX = Math.floor(deltaX);
            } else {
                deltaX = Math.ceil(deltaX);
            }
            if (deltaY < 0) {
                deltaY = Math.floor(deltaY);
            } else {
                deltaY = Math.ceil(deltaY);
            }

            if (deltaX > 0) _x -= Math.abs(deltaX);
            else if (deltaX < 0) _x += Math.abs(deltaX);
            if (deltaY < 0) _y += Math.abs(deltaY);
            else if (deltaY > 0) _y -= Math.abs(deltaY);
            box.translate(_x, _y, layer.parent);
        }
    }
    void mouseClicked(int mx, int my, int button) {
        if(layer.debug){
            //println("x:"+mx+" || "+"y:"+my);
        }
        if (!mapScreen) return;
        if (driveFlag) return;

        // The mouse co-ordinates must be offset by the position of the ViewBox
        // for scrolling and zooming to work properly
        var layerCoords = layer.mapCoordinateFromScreen(mx, my);
        mx = layerCoords[0];
        my = layerCoords[1];

        // Did we click on the vehicle? If not, check if we clicked on a road
        if (button == LEFT && over(mx,my)) {
            if (destination.length > 0) driveToDestination();
        } else {
            // Get the hexadecimal colour code at the clicked point on the shadowMap
            color c = shadowMap.get(mx, my);
            c = hex(c);
            if (DISPLAY_SHADOWMAP) console.log(c);

            /* Clicking the left mouse button on a valid road segment highlights that segment and
             * updates the final destination for the vehicle to travel to. Clicking the right
             * mouse button on a valid road segment removes its highlight and updates the vehicle's
             * final destination to the previous node in the route.
             */
            if (shadowMapColorDictionary[c] != null && button == LEFT) {
                var flippedVertexX = shadowMapColorDictionary[c][0].vertex.x -
                    shadowMapColorDictionary[c][1].vertex.x > 0 ? true : false;
                var flippedVertexY = shadowMapColorDictionary[c][0].vertex.y -
                    shadowMapColorDictionary[c][1].vertex.y > 0 ? true : false;

                if (shadowMapColorDictionary[c][0].vertex.equals(futurePosition)) {
                    destination.push(shadowMapColorDictionary[c][1]);
                    if (!flippedVertexX && !flippedVertexY) {
                        roadSelectedDictionary[c][0] += 1;
                    } else if (flippedVertexX || flippedVertexY) {
                        roadSelectedDictionary[c][1] += 1;
                    }
                    futurePosition = shadowMapColorDictionary[c][1].vertex;
                    currDestColorID.push(c);
                } else if (shadowMapColorDictionary[c][1].vertex.equals(futurePosition)) {
                    destination.push(shadowMapColorDictionary[c][0]);
                    if (!flippedVertexX && !flippedVertexY) {
                        roadSelectedDictionary[c][1] += 1;
                    } else if (flippedVertexX || flippedVertexY) {
                        roadSelectedDictionary[c][0] += 1;
                    }
                    futurePosition = shadowMapColorDictionary[c][0].vertex;
                    currDestColorID.push(c);
                }
            } else if (shadowMapColorDictionary[c] != null && button == RIGHT) {
                var prevDest, index, delta = 0;

                if (destination.length > 1) {
                    prevDest = destination[destination.length - 2].vertex;
                } else if (destination.length == 1) {
                    prevDest = currentPosition;
                } else {
                    return;
                }

                if (futurePosition.x - prevDest.x == 0) {
                    delta = futurePosition.y - prevDest.y;
                    index = delta < 0 ? 1 : 0;
                } else if (futurePosition.y - prevDest.y == 0) {
                    delta = futurePosition.x - prevDest.x;
                    index = delta < 0 ? 1 : 0;
                }

                if (roadSelectedDictionary[c][index] > 0 &&
                        c == currDestColorID[currDestColorID.length - 1]) {
                    roadSelectedDictionary[c][index] -= 1;
                    destination.pop();
                    if (destination.length > 0) {
                        futurePosition = destination[destination.length - 1].vertex;
                    } else {
                        futurePosition = currentPosition;
                    }
                    currDestColorID.pop();
                }
            }
        }
    }
    void setStates() {
        addState(new State("Player", assetsFolder+"car.png"));
    }
    void stopVehicle() {
        stop();
        edgeDelta = 0;
    }
}
