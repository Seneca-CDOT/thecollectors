/**
 *  Controls the car. Handles user input.
 */

class Driver extends Player{
    var currentPosition, previousPosition, destination, currDest;
    var edgeDelta = 0, roadDeltaX = 0, roadDeltaY = 0, direction = 0;
    var currDestColorID, nodeMap, fuelGauge, fuelCost;
    var destinationWeight, deltaPerTick, tickDelta = 0, previousVehicleDelta = 0;
    var fuelGaugeHUD, fuelNeedleHUD, cashHUD, needlePosition = 0, needleDelta = 0;
    var cashAnimHUD, cashAnimEl, cashAnimEl2;
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
        fractionBox = document.getElementById("fractionBoxDiv");
        fractionImg = document.getElementById("fractionBonusImg");
        fractionText = document.getElementById("fractionTextDiv");
        fractionCT = null;
        cashAnimEl = document.getElementById("cashAnimElement");
        cashAnimEl2 = document.getElementById("cashAnimElement2");
        fuelGauge = new Fraction(nodeMap.fuel.numerator, nodeMap.fuel.denominator);
        fuelGaugeHUD = document.getElementById("fuelElement2");
        fuelGaugeHUD.innerHTML = fuelGauge.numerator.toString();
        fuelGaugeHUD.innerHTML += "<br /><hr />";
        fuelGaugeHUD.innerHTML += fuelGauge.denominator.toString();
        needleDelta = NEEDLE_RANGE / fuelGauge.denominator;
        fuelNeedleHUD = document.getElementById("fuelNeedle");
        cashHUD = document.getElementById("cashElement");
        cashHUD.innerHTML = "$" + levelCash;
        parcelHUD = document.getElementById("parcelElement");
        parcelHUD.innerHTML = "x " + deliveriesLeft;
        var fuelCostWeight = 1.0 - (0.6 - gameDifficulty * 0.2);
        fuelCost = Math.floor(StructureValues.fuel_stn * fuelCostWeight / fuelGauge.denominator);
        bonusTracker.array = [];
        bonusTracker.initialBonusIndex = -1;
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
                }
                if (keyCode==BACKSPACE) {
                    clearRoute();
                }
                if (keyCode==DELETE) {
                    if (destination.length == 1 ||
                            (destination.length > 0 && bonusTracker.initialBonusIndex == -1)) {
                        driveToDestination();
                    } else {
                        if (destination.length > 0 && !showFractionBox) {
                            $("#fractionBoxDiv").show();
                            $("#fractionBonusImg").show();
                            $("#fractionBackImg").show();
                            $("#fracSumNum").focus();
                            $("#fuelWrap").hide();
                            showFractionBox = true;
                        }
                    }
                }
                box.translate(_x,_y,layer.parent,layer.xScale, layer.yScale);
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
    void clearRoute() {
        if (GEN_TUTORIAL) return;
        if (!mapScreen) return;
        if (showFractionBox) return;
        if (driveFlag) return;

        bonusTracker.array.length = 0;
        bonusTracker.initialBonusIndex = -1;
        fractionArray.length = 0;
        futurePosition = currentPosition;
        destination.length = 0;
        var len = currDestColorID.length;
        for (var i = 0; i < len; i++) {
            roadSelectedDictionary[currDestColorID[i]][0] = 0;
            roadSelectedDictionary[currDestColorID[i]][1] = 0;
        }
        currDestColorID.length = 0;
        fractionText.innerHTML = "";
    }
    void mouseMoved(int mx, int my){
        canvasHasFocus=true;
    }
    void driveToDestination() {

        var impulseX = 0, impulseY = 0;

        refueled = false;
        fractionArray.length = 0;
        if (bonusTracker.array.length > 0) {
            bonusTracker.array.length = 0;
            bonusTracker.initialBonusIndex = -1;
        }
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

        // Calculate the distance that the vehicle travels
        // across the current edge on one "tick" of fuel
        deltaPerTick = edgeDelta / destinationWeight.numerator;

        driveFlag = true;
        if (needlePosition > -NEEDLE_RANGE) {
            animateNeedle(30, -needleDelta, needlePosition);
            needlePosition -= needleDelta;
        }
    }
    boolean structureCheck(currentNodeID) {
        // Get the structure list
        
        var sL = nodeMap.pjsStructureList;
        var s = sL[currentNodeID];
        if(s){
            if (s.structObject.StructType == "fuel_stn") {
                s.structObject.visited = true;
            }
            return true;
        }
        return false;
    }
    // If the current structure is a delivery location, add points,
    // if it is a fuel station reduce cash but increase fuel capacity
    void updateInfo(atStruct){
        if (atStruct.StructType != "fuel_stn" && !atStruct.visited) {
            if (bonusFlag) {
                levelCash += BONUS_CASH_AMT;
                cashAnimEl2.innerHTML = "+$" + BONUS_CASH_AMT + " (Bonus)";
                animateBonus();
            }
            levelCash += atStruct.Points;
            atStruct.visited = true;
            deliveriesLeft--;
            cashHUD.innerHTML = "$" + levelCash;
            parcelHUD.innerHTML = "x " + deliveriesLeft;
            cashAnimEl.innerHTML = "+$" + atStruct.Points;
            $("#cashAnimDiv").show();
            animateCash();
        }
        else if (atStruct.StructType == "fuel_stn" && !refueled) {
            refueled = true;
            var fuelMissing = fuelGauge.denominator - fuelGauge.numerator;
            var totalFuelCost = fuelMissing * fuelCost;
            var enoughCash = (levelCash - totalFuelCost) >= 0 ? true : false;
            var fuelString = 0;
            if (enoughCash) {
                levelCash -= totalFuelCost;
                fuelString = totalFuelCost;
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
                    fuelString = total;
                    fuelGauge.numerator += ticksToFill;
                    needlePosition += ticksToFill * needleDelta;
                }
            }
            if (fuelString > 0) {
                cashHUD.innerHTML = "$" + levelCash;
                var costString = "&nbsp;&#8211;$" + fuelString;
                animateCost(costString);
            }
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
        if(deliveriesLeft <= 0){
            if (!GEN_TUTORIAL) {
                nextMap();
            }
            return;
        }
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
                bonusFlag = false;
            }
        }

        if (!gameOver && edgeDelta > 0 && tickDelta >= deltaPerTick) {
            tickDelta = 0;
            if (needlePosition > -NEEDLE_RANGE) {
                animateNeedle(30, -needleDelta, needlePosition);
                needlePosition -= needleDelta;
            }
            consumeFuel();
            checkIfFuelEmpty();
        }
        // Draw the vehicle
        super.drawObject();
    }
    // Subtract the fraction from the fuel gauge and update the HUD
    void consumeFuel() {
        fuelGauge.numerator -= 1;
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
    void mouseReleased(int mx, int my, int button) {
        cursor(ARROW);
    }
    void mouseDragged(int mx, int my, int button) {
        if (mapScreen && button == LEFT) {
            cursor(MOVE);
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
            box.translate(_x, _y, layer.parent, layer.xScale, layer.yScale);
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
            if (destination.length == 1 ||
                    (destination.length > 0 && bonusTracker.initialBonusIndex == -1)) {
                driveToDestination();
            } else {
                if (destination.length > 0 && !showFractionBox) {
                    $("#fractionBoxDiv").show();
                    $("#fractionBonusImg").show();
                    $("#fractionBackImg").show();
                    $("#fracSumNum").focus();
                    $("#fuelWrap").hide();
                    showFractionBox = true;
                }
            }
        } else if (destination.length < 10 || button == RIGHT) {
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
                var fraction = null;

                if (shadowMapColorDictionary[c][0].vertex.equals(futurePosition)) {
                    destination.push(shadowMapColorDictionary[c][1]);
                    if (!flippedVertexX && !flippedVertexY) {
                        roadSelectedDictionary[c][0] += 1;
                    } else if (flippedVertexX || flippedVertexY) {
                        roadSelectedDictionary[c][1] += 1;
                    }
                    fraction = shadowMapColorDictionary[c][0].connections[destination[destination.length - 1].id];
                    futurePosition = shadowMapColorDictionary[c][1].vertex;
                    var st = nodeMap.pjsStructureList[shadowMapColorDictionary[c][1].id];
                    if (st) {
                        if (st.structObject.StructType != "fuel_stn" && !st.structObject.visited) {
                            bonusTracker.array.push(true);
                            if (bonusTracker.initialBonusIndex == -1) {
                                bonusTracker.initialBonusIndex = bonusTracker.array.length - 1;
                            }
                        } else {
                            bonusTracker.array.push(false);
                        }
                    } else {
                        bonusTracker.array.push(false);
                    }
                    currDestColorID.push(c);

                    if (destination.length > 1) {
                        fractionCT.innerHTML += "<div style=\"float:left;padding-top:29px;\">+</div>" +
                            "<div style=\"margin:1px;float:left;width:45px;\">" +
                            "<div id=\"fraction" + destination.length +
                            "\" style=\"text-align:center;margin:10px;\"></div></div>";

                        var fracElement = document.getElementById("fraction" + destination.length);
                        fracElement.innerHTML = fraction.displayNum != undefined ? fraction.displayNum.toString() :
                            fraction.numerator.toString();
                        fracElement.innerHTML += "<br /><hr />";
                        fracElement.innerHTML += fraction.displayDenom != undefined ?
                            fraction.displayDenom.toString() : fraction.denominator.toString();

                        fractionArray.push(fraction);
                    }
                } else if (shadowMapColorDictionary[c][1].vertex.equals(futurePosition)) {
                    destination.push(shadowMapColorDictionary[c][0]);
                    if (!flippedVertexX && !flippedVertexY) {
                        roadSelectedDictionary[c][1] += 1;
                    } else if (flippedVertexX || flippedVertexY) {
                        roadSelectedDictionary[c][0] += 1;
                    }
                    fraction = shadowMapColorDictionary[c][1].connections[destination[destination.length - 1].id];
                    futurePosition = shadowMapColorDictionary[c][0].vertex;
                    var st = nodeMap.pjsStructureList[shadowMapColorDictionary[c][0].id];
                    if (st) {
                        if (st.structObject.StructType != "fuel_stn" && !st.structObject.visited) {
                            bonusTracker.array.push(true);
                            if (bonusTracker.initialBonusIndex == -1) {
                                bonusTracker.initialBonusIndex = bonusTracker.array.length - 1;
                            }
                        } else {
                            bonusTracker.array.push(false);
                        }
                    } else {
                        bonusTracker.array.push(false);
                    }
                    currDestColorID.push(c);

                    if (destination.length > 1) {
                        fractionCT.innerHTML += "<div style=\"float:left;padding-top:29px;\">+</div>" +
                            "<div style=\"margin:1px;float:left;width:45px;\">" +
                            "<div id=\"fraction" + destination.length +
                            "\" style=\"text-align:center;margin:10px;\"></div></div>";

                        var fracElement = document.getElementById("fraction" + destination.length);
                        fracElement.innerHTML = fraction.displayNum != undefined ? fraction.displayNum.toString() :
                            fraction.numerator.toString();
                        fracElement.innerHTML += "<br /><hr />";
                        fracElement.innerHTML += fraction.displayDenom != undefined ?
                            fraction.displayDenom.toString() : fraction.denominator.toString();

                        fractionArray.push(fraction);
                    }
                }
                if (fraction != null && destination.length == 1) {
                    fractionText.innerHTML = "<div id=\"fractionCT\" class=\"inCanvas\"" +
                        "style=\"position:absolute;width:80%;\"></div><div id=\"submitDiv\"" +
                        "style=\"position:absolute;left:80%;width:20%;\"></div>";
                    fractionCT = document.getElementById("fractionCT");
                    fractionCT.innerHTML = "<div style=\"margin:1px;float:left;width:45px;\">" +
                        "<div id=\"fraction" + destination.length +
                        "\" style=\"text-align:center;margin:10px;\"></div></div>";

                    // Add the div containing the input textboxes to the overlay
                    var submitBox = document.getElementById("submitDiv");
                    submitBox.innerHTML += "<div style=\"margin:1px;float:right;width:70px;\">" +
                        "<div id=\"fractionSubmit\"" +
                        "style=\"width:64px;height:64px;background-color:white;margin:5px;\"" +
                        "onclick=\"checkFractionSum()\" >" +
                        "<img src=\"./assets/items/drive_btn.png\" width=\"64px\" height=\"64px\"/></div></div>" +
                        "<div style=\"margin:1px;float:right;width:45px;\">" +
                        "<div id=\"fractionSum\" style=\"text-align:center;\"></div></div>" +
                        "<div style=\"float:right;padding-top:29px;\">=</div>";

                    var fracElement = document.getElementById("fraction" + destination.length);
                    fracElement.innerHTML = fraction.displayNum != undefined ? fraction.displayNum.toString() :
                        fraction.numerator.toString();
                    fracElement.innerHTML += "<br /><hr />";
                    fracElement.innerHTML += fraction.displayDenom != undefined ?
                        fraction.displayDenom.toString() : fraction.denominator.toString();

                    fractionArray.push(fraction);

                    var fracSum = document.getElementById("fractionSum");
                    fracSum.innerHTML = "<div id=\"fractionNum\" style=\"padding:1px;margin:3px;border-radius:3px;\"><input type=\"text\" id=\"fracSumNum\" name=\"numerator\" autocomplete=\"off\" onblur=\"testInput(this)\"" +
                        "onfocus=\"fracHideTooltip(this)\" style=\"width:23px\" /></div>" +
                        "<hr />" +
                        "<div id=\"fractionDenom\" style=\"margin:3px;border-radius:3px;\"><input type=\"text\" id=\"fracSumDenom\" name=\"denominator\" autocomplete=\"off\" onblur=\"testInput(this)\"" +
                        "onfocus=\"fracHideTooltip(this)\" style=\"width:23px\" /></div>";
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
                    fractionArray.pop();
                    bonusTracker.array.pop();
                    if (bonusTracker.array.length <= bonusTracker.initialBonusIndex) {
                        bonusTracker.initialBonusIndex = -1;
                    }
                    if (destination.length > 0) {
                        futurePosition = destination[destination.length - 1].vertex;

                        // Remove the div elements containing the fraction and the "+" sign
                        var node = fractionCT.children[fractionCT.childElementCount - 1];
                        node.parentNode.removeChild(node);
                        node = fractionCT.children[fractionCT.childElementCount - 1];
                        node.parentNode.removeChild(node);
                    } else {
                        futurePosition = currentPosition;
                        $("#fuelWrap").show();
                        fractionText.innerHTML = "";
                    }
                    currDestColorID.pop();
                }
            }
        }
    }
    void setStates() {
        setScale(0.6);
        addState(new State("Player", assetsFolder+"vehicles/"+vehicleTypes[currentVehicle][0]));
    }
    void stopVehicle() {
        stop();
        edgeDelta = 0;
    }
}

class TutorialDriver extends Driver {
    TutorialDriver(map) {
        super(map);
    }
    void drawObject() {
        // Tutorial position tests
        if (GEN_TUTORIAL && tutorialIndex == 11 && currentPosition.x == 400 && currentPosition.y == 200) {
            $("#tutorialTextDiv").show();
            $("#instructionTextDiv").hide();
            document.getElementById("instructionTextElement").innerHTML = instructionText[++instructionIndex];
            advanceTutorial();
        } else if (GEN_TUTORIAL && tutorialIndex == 16 && currentPosition.x == 300 && currentPosition.y == 200) {
            $("#tutorialTextDiv").show();
            $("#instructionTextDiv").hide();
            document.getElementById("instructionTextElement").innerHTML = instructionText[++instructionIndex];
            advanceTutorial();
        } else if (GEN_TUTORIAL && tutorialIndex == 27 && currentPosition.x == 300 && currentPosition.y == 400) {
            document.getElementById("tutorialTextElement").innerHTML = tutorialText[++tutorialIndex];
            $("#tutorialTextDiv").show();
            $("#highlightBox").css("left", "40px");
            $("#highlightBox").css("top", "0px");
            $("#highlightBox").css("width", "100px");
            $("#highlightBox").css("height", "36px");
            $("#highlightBox").show();
        } else if (GEN_TUTORIAL && tutorialIndex == 31 && currentPosition.x == 400 && currentPosition.y == 500) {
            $("#tutorialTextDiv").show();
            $("#instructionTextDiv").hide();
            document.getElementById("instructionTextElement").innerHTML = instructionText[++instructionIndex];
            advanceTutorial();
        } else if (GEN_TUTORIAL && tutorialIndex == 35 && currentPosition.x == 400 && currentPosition.y == 800) {
            document.getElementById("tutorialTextElement").innerHTML = tutorialText[++tutorialIndex];
        }

        super.drawObject();
    }
    void handleInput() {
        if (canvasHasFocus && mapScreen) {
            if (keyCode){
                ViewBox box=layer.parent.viewbox;
                int _x=0, _y=0;
                if(keyCode==UP){
                    if (GEN_TUTORIAL && tutorialIndex < 3) {
                        // do nothing
                    } else {
                    _y-=arrowSpeed;
                    }
                }
                if(keyCode==DOWN){
                    if (GEN_TUTORIAL && tutorialIndex < 3) {
                        // do nothing
                    } else {
                    _y+=arrowSpeed;
                    }
                }
                if(keyCode==LEFT){
                    if (GEN_TUTORIAL && tutorialIndex < 3) {
                        // do nothing
                    } else {
                    _x-=arrowSpeed;
                    }
                }
                if(keyCode==RIGHT){
                    if (GEN_TUTORIAL && tutorialIndex < 3) {
                        // do nothing
                    } else {
                    _x+=arrowSpeed;
                    }
                }
                if (keyCode==ENTER) {
                    if (GEN_TUTORIAL && (tutorialIndex == 3 || tutorialIndex == 6 || tutorialIndex == 11 ||
                                tutorialIndex == 16 || tutorialIndex == 22 ||
                                tutorialIndex == 27 || tutorialIndex == 31 || tutorialIndex == 35)) {
                        keyCode = undefined;
                        return;
                    }
                    advanceTutorial();
                }
                if (keyCode==DELETE) {
                    if (destination.length == 1 ||
                            (destination.length > 0 && bonusTracker.initialBonusIndex == -1)) {
                        driveToDestination();
                    } else {
                        if (destination.length > 0 && !showFractionBox) {
                            $("#fractionBoxDiv").show();
                            $("#fractionBonusImg").show();
                            $("#fractionBackImg").show();
                            $("#fracSumNum").focus();
                            $("#fuelWrap").hide();
                            showFractionBox = true;
                        }
                    }
                    // Change opacity of tutorial text div during the bonus overlay
                    if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 2) {
                        document.getElementById("tutorialTextElement").innerHTML = tutorialText[++tutorialIndex];
                        $("#tutorialTextDiv").css("opacity", "1.0");
                        $("#highlightBox").css("left", "100px");
                        $("#highlightBox").css("top", "344px");
                        $("#highlightBox").css("width", "600px");
                        $("#highlightBox").css("height", "70px");
                        $("#highlightBox").show();
                    }
                }
                box.translate(_x,_y,layer.parent,layer.xScale, layer.yScale);

                // Test to see if player scrolled the map in the downward direction
                ViewBox box = layer.parent.viewbox;
                if (box.x <= 265 && box.y >= 260 && tutorialIndex == 3) {
                    $("#tutorialTextDiv").show();
                    $("#instructionTextDiv").hide();
                    document.getElementById("instructionTextElement").innerHTML = instructionText[++instructionIndex];
                    advanceTutorial();
                }
            }
            if(mouseScroll!=0){
                if (GEN_TUTORIAL && tutorialIndex < 6) {
                    // do nothing
                } else {
                    layer.zoom(mouseScroll/10);
                    mouseScroll=0;
                }
            }
            if(isKeyDown('+') || isKeyDown('=')){
                if (GEN_TUTORIAL && tutorialIndex < 6) {
                    // do nothing
                } else {
                    layer.zoom(1/3/10);
                }
            }
            if(isKeyDown('-')){
                if (GEN_TUTORIAL && tutorialIndex < 6) {
                    // do nothing
                } else {
                    layer.zoom(-1/3/10);
                }
            }
            if(isKeyDown(' ')){                     //key is subject to change
                ViewBox box=layer.parent.viewbox;
                box.track(layer.parent,this);
            }
        }
        mouseScroll=0;
        keyCode=undefined;
    }
    void mouseDragged(int mx, int my, int button) {
        // If playing tutorial, disable scrolling until the tutorial explicitly
        // asks player to perform it and when the tutorial has concluded.
        if (GEN_TUTORIAL && (tutorialIndex < 3 || tutorialIndex == 36))
            return;
        else if (GEN_TUTORIAL && tutorialIndex == 3) {
            // Test to see if player scrolled the map in the downward direction
            ViewBox box = layer.parent.viewbox;
            if (box.x <= 265 && box.y >= 260) {
                $("#tutorialTextDiv").show();
                $("#instructionTextDiv").hide();
                document.getElementById("instructionTextElement").innerHTML = instructionText[++instructionIndex];
                advanceTutorial();
            }
        }
        super.mouseDragged(mx, my, button);
    }
    void mouseClicked(int mx, int my, int button) {
        // To prevent user from selecting and driving down roads
        // before a specific point in the tutorial is reached
        if (GEN_TUTORIAL && tutorialIndex < 37 && tutorialIndex != 31 && tutorialIndex != 11 &&
                tutorialIndex != 16 && tutorialIndex != 22 && tutorialIndex != 27 &&
                tutorialIndex != 35) return;

        if (!mapScreen) return;
        if (driveFlag) return;

        // The mouse co-ordinates must be offset by the position of the ViewBox
        // for scrolling and zooming to work properly
        var layerCoords = layer.mapCoordinateFromScreen(mx, my);
        mx = layerCoords[0];
        my = layerCoords[1];

        // Did we click on the vehicle? If not, check if we clicked on a road
        if (button == LEFT && over(mx,my)) {
            // Don't let the vehicle drive unless a number of roads have been selected
            // during the correct sections of the tutorial
            if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length < 2) return;
            if (GEN_TUTORIAL && tutorialIndex == 27 && destination.length < 2) return;
            if (GEN_TUTORIAL && tutorialIndex == 31 && destination.length < 2) return;
            if (destination.length == 1 ||
                    (destination.length > 0 && bonusTracker.initialBonusIndex == -1)) {
                driveToDestination();
            } else {
                if (destination.length > 0 && !showFractionBox) {
                    $("#fractionBoxDiv").show();
                    $("#fractionBonusImg").show();
                    $("#fractionBackImg").show();
                    $("#fracSumNum").focus();
                    $("#fuelWrap").hide();
                    showFractionBox = true;
                }
                // Change opacity of tutorial text div during the bonus overlay
                if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 2) {
                    document.getElementById("tutorialTextElement").innerHTML = tutorialText[++tutorialIndex];
                    $("#tutorialTextDiv").css("opacity", "1.0");
                    $("#highlightBox").css("left", "100px");
                    $("#highlightBox").css("top", "344px");
                    $("#highlightBox").css("width", "600px");
                    $("#highlightBox").css("height", "70px");
                    $("#highlightBox").show();
                }
            }
        // Prevents selecting more than 10 roads but allows right-clicks to
        // execute de-selection
        } else if (destination.length < 10 || button == RIGHT) {
            if (GEN_TUTORIAL && tutorialIndex == 11 && destination.length == 1) return;
            if (GEN_TUTORIAL && tutorialIndex == 16 && destination.length == 1) return;
            if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 2) return;
            if (GEN_TUTORIAL && tutorialIndex == 27 && destination.length == 2) return;
            if (GEN_TUTORIAL && tutorialIndex == 31 && destination.length == 2) return;
            if (GEN_TUTORIAL && tutorialIndex == 35 && destination.length == 1) return;
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
                var fraction = null;

                if (shadowMapColorDictionary[c][0].vertex.equals(futurePosition)) {
                    // Tutorial checks
                    var vtx = shadowMapColorDictionary[c][1].vertex;
                    if (GEN_TUTORIAL && tutorialIndex == 16 && (vtx.x != 300 || vtx.y != 200)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 0 &&
                            (vtx.x != 300 || vtx.y != 300)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 1 &&
                            (vtx.x != 300 || vtx.y != 400)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 27 && destination.length == 0 &&
                            (vtx.x != 300 || vtx.y != 300)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 27 && destination.length == 1 &&
                            (vtx.x != 300 || vtx.y != 400)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 31 && destination.length == 0 &&
                            (vtx.x != 400 || vtx.y != 400)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 31 && destination.length == 1 &&
                            (vtx.x != 400 || vtx.y != 500)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 35 && destination.length == 0 &&
                            (vtx.x != 400 || vtx.y != 800)) return;

                    destination.push(shadowMapColorDictionary[c][1]);
                    if (!flippedVertexX && !flippedVertexY) {
                        roadSelectedDictionary[c][0] += 1;
                    } else if (flippedVertexX || flippedVertexY) {
                        roadSelectedDictionary[c][1] += 1;
                    }
                    fraction = shadowMapColorDictionary[c][0].connections[destination[destination.length - 1].id];
                    futurePosition = shadowMapColorDictionary[c][1].vertex;
                    var st = nodeMap.pjsStructureList[shadowMapColorDictionary[c][1].id];
                    if (st) {
                        if (st.structObject.StructType != "fuel_stn" && !st.structObject.visited) {
                            bonusTracker.array.push(true);
                            if (bonusTracker.initialBonusIndex == -1) {
                                bonusTracker.initialBonusIndex = bonusTracker.array.length - 1;
                            }
                        } else {
                            bonusTracker.array.push(false);
                        }
                    } else {
                        bonusTracker.array.push(false);
                    }
                    currDestColorID.push(c);

                    if (destination.length > 1) {
                        fractionCT.innerHTML += "<div style=\"float:left;padding-top:29px;\">+</div>" +
                            "<div style=\"margin:1px;float:left;width:45px;\">" +
                            "<div id=\"fraction" + destination.length +
                            "\" style=\"text-align:center;margin:10px;\"></div></div>";

                        var fracElement = document.getElementById("fraction" + destination.length);
                        fracElement.innerHTML = fraction.displayNum != undefined ? fraction.displayNum.toString() :
                            fraction.numerator.toString();
                        fracElement.innerHTML += "<br /><hr />";
                        fracElement.innerHTML += fraction.displayDenom != undefined ?
                            fraction.displayDenom.toString() : fraction.denominator.toString();

                        fractionArray.push(fraction);
                    }
                } else if (shadowMapColorDictionary[c][1].vertex.equals(futurePosition)) {
                    // Tutorial checks
                    var vtx = shadowMapColorDictionary[c][0].vertex;
                    if (GEN_TUTORIAL && tutorialIndex == 16 && (vtx.x != 300 || vtx.y != 200)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 0 &&
                            (vtx.x != 300 || vtx.y != 300)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 22 && destination.length == 1 &&
                            (vtx.x != 300 || vtx.y != 400)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 27 && destination.length == 0 &&
                            (vtx.x != 300 || vtx.y != 300)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 27 && destination.length == 1 &&
                            (vtx.x != 300 || vtx.y != 400)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 31 && destination.length == 0 &&
                            (vtx.x != 400 || vtx.y != 400)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 31 && destination.length == 1 &&
                            (vtx.x != 400 || vtx.y != 500)) return;
                    if (GEN_TUTORIAL && tutorialIndex == 35 && destination.length == 0 &&
                            (vtx.x != 400 || vtx.y != 800)) return;

                    destination.push(shadowMapColorDictionary[c][0]);
                    if (!flippedVertexX && !flippedVertexY) {
                        roadSelectedDictionary[c][1] += 1;
                    } else if (flippedVertexX || flippedVertexY) {
                        roadSelectedDictionary[c][0] += 1;
                    }
                    fraction = shadowMapColorDictionary[c][1].connections[destination[destination.length - 1].id];
                    futurePosition = shadowMapColorDictionary[c][0].vertex;
                    var st = nodeMap.pjsStructureList[shadowMapColorDictionary[c][0].id];
                    if (st) {
                        if (st.structObject.StructType != "fuel_stn" && !st.structObject.visited) {
                            bonusTracker.array.push(true);
                            if (bonusTracker.initialBonusIndex == -1) {
                                bonusTracker.initialBonusIndex = bonusTracker.array.length - 1;
                            }
                        } else {
                            bonusTracker.array.push(false);
                        }
                    } else {
                        bonusTracker.array.push(false);
                    }
                    currDestColorID.push(c);

                    if (destination.length > 1) {
                        fractionCT.innerHTML += "<div style=\"float:left;padding-top:29px;\">+</div>" +
                            "<div style=\"margin:1px;float:left;width:45px;\">" +
                            "<div id=\"fraction" + destination.length +
                            "\" style=\"text-align:center;margin:10px;\"></div></div>";

                        var fracElement = document.getElementById("fraction" + destination.length);
                        fracElement.innerHTML = fraction.displayNum != undefined ? fraction.displayNum.toString() :
                            fraction.numerator.toString();
                        fracElement.innerHTML += "<br /><hr />";
                        fracElement.innerHTML += fraction.displayDenom != undefined ?
                            fraction.displayDenom.toString() : fraction.denominator.toString();

                        fractionArray.push(fraction);
                    }
                }
                if (fraction != null && destination.length == 1) {
                    if (GEN_TUTORIAL && tutorialIndex == 11) {
                        document.getElementById("instructionTextElement").innerHTML = instructionText[++instructionIndex];
                    }
                    fractionText.innerHTML = "<div id=\"fractionCT\" class=\"inCanvas\"" +
                        "style=\"position:absolute;width:80%;\"></div><div id=\"submitDiv\"" +
                        "style=\"position:absolute;left:80%;width:20%;\"></div>";
                    fractionCT = document.getElementById("fractionCT");
                    fractionCT.innerHTML = "<div style=\"margin:1px;float:left;width:45px;\">" +
                        "<div id=\"fraction" + destination.length +
                        "\" style=\"text-align:center;margin:10px;\"></div></div>";

                    // Add the div containing the input textboxes to the overlay
                    var submitBox = document.getElementById("submitDiv");
                    submitBox.innerHTML += "<div style=\"margin:1px;float:right;width:70px;\">" +
                        "<div id=\"fractionSubmit\"" +
                        "style=\"width:64px;height:64px;background-color:white;margin:5px;\"" +
                        "onclick=\"checkFractionSum()\" >" +
                        "<img src=\"./assets/items/drive_btn.png\" width=\"64px\" height=\"64px\"/></div></div>" +
                        "<div style=\"margin:1px;float:right;width:45px;\">" +
                        "<div id=\"fractionSum\" style=\"text-align:center;\"></div></div>" +
                        "<div style=\"float:right;padding-top:29px;\">=</div>";

                    var fracElement = document.getElementById("fraction" + destination.length);
                    fracElement.innerHTML = fraction.displayNum != undefined ? fraction.displayNum.toString() :
                        fraction.numerator.toString();
                    fracElement.innerHTML += "<br /><hr />";
                    fracElement.innerHTML += fraction.displayDenom != undefined ?
                        fraction.displayDenom.toString() : fraction.denominator.toString();

                    fractionArray.push(fraction);

                    var fracSum = document.getElementById("fractionSum");
                    fracSum.innerHTML = "<div id=\"fractionNum\" style=\"padding:1px;margin:3px;border-radius:3px;\"><input type=\"text\" id=\"fracSumNum\" name=\"numerator\" autocomplete=\"off\" onblur=\"testInput(this)\"" +
                        "onfocus=\"fracHideTooltip(this)\" style=\"width:23px\" /></div>" +
                        "<hr />" +
                        "<div id=\"fractionDenom\" style=\"margin:3px;border-radius:3px;\"><input type=\"text\" id=\"fracSumDenom\" name=\"denominator\" autocomplete=\"off\" onblur=\"testInput(this)\"" +
                        "onfocus=\"fracHideTooltip(this)\" style=\"width:23px\" /></div>";
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
                    fractionArray.pop();
                    bonusTracker.array.pop();
                    if (bonusTracker.array.length <= bonusTracker.initialBonusIndex) {
                        bonusTracker.initialBonusIndex = -1;
                    }
                    if (destination.length > 0) {
                        futurePosition = destination[destination.length - 1].vertex;

                        // Remove the div elements containing the fraction and the "+" sign
                        var node = fractionCT.children[fractionCT.childElementCount - 1];
                        node.parentNode.removeChild(node);
                        node = fractionCT.children[fractionCT.childElementCount - 1];
                        node.parentNode.removeChild(node);
                    } else {
                        futurePosition = currentPosition;
                        $("#fuelWrap").show();
                        fractionText.innerHTML = "";
                    }
                    currDestColorID.pop();
                }
            }
        }
    }
}
