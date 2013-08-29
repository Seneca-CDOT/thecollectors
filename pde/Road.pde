/**
 *  Handles drawing of roads and their fraction values.
 */

class Road extends Interactor {
    var vertex1;
    var vertex2;

    PFont fracFont;
    var fracText = "";
    var currX = 0, currY = 0;
    var roadBounds = [], roadSelection = [], roadSelection2 = [];
    var cID, vFlippedX, vFlippedY, horizontal, vertical;
    Road(id, vert1, vert2, frac) {
        super("Road");
        vertex1 = vert1;
        vertex2 = vert2;
        fracFont = loadFont("EurekaMonoCond-Bold.ttf");
        textFont(fracFont, 14);
        textLeading(9);
        if(gameDifficulty>1 || currentLevel==5){
            if(rng(1,10)<=(2+gameDifficulty+currentLevel))
               frac.genAltDisplay();
        }
        fracText = frac.toString();
        //fracText = frac.numerator.toString() + "\n—\n" + frac.denominator.toString();
        // Associate the road segment with its shadowMap road's hexadecimal colour code
        cID = id;
        horizontal = vertex1.y - vertex2.y == 0 ? true : false;
        vertical = vertex1.x - vertex2.x == 0 ? true : false;
        calculateBounds();
    }
    // Calculate the box that acts as the highlight for the road segment
    void calculateBounds() {
        vFlippedX = (vertex1.x - vertex2.x) <= 0 ? false : true;
        vFlippedY = (vertex1.y - vertex2.y) <= 0 ? false : true;
        if (vertex1.x - vertex2.x == 0 && !vFlippedY) {
            roadSelection[0] = vertex1.x - 9;
            roadSelection[1] = vertex1.y + 30;
            roadSelection[2] = vertex2.x - 3;
            roadSelection[3] = vertex2.y - 50;
            roadSelection[4] = vertex2.x - 6;
            roadSelection[5] = vertex2.y - 40;
            roadSelection[6] = vertex1.x - 9;
            roadSelection[7] = vertex2.y - 50;
            roadSelection[8] = vertex2.x - 3;
            roadSelection[9] = vertex2.y - 50;
            roadSelection2[0] = vertex1.x + 3;
            roadSelection2[1] = vertex1.y + 50;
            roadSelection2[2] = vertex2.x + 9;
            roadSelection2[3] = vertex2.y - 30;
            roadSelection2[4] = vertex1.x + 6;
            roadSelection2[5] = vertex1.y + 40;
            roadSelection2[6] = vertex1.x + 9;
            roadSelection2[7] = vertex1.y + 50;
            roadSelection2[8] = vertex1.x + 3;
            roadSelection2[9] = vertex1.y + 50;
            roadBounds[0] = vertex1.x - 12;
            roadBounds[1] = vertex1.y + 11;
            roadBounds[2] = vertex2.x + 12;
            roadBounds[3] = vertex2.y - 11;
        } else if (vertex1.x - vertex2.x == 0 && vFlippedY) {
            roadSelection[0] = vertex2.x - 9;
            roadSelection[1] = vertex2.y + 30;
            roadSelection[2] = vertex1.x - 3;
            roadSelection[3] = vertex1.y - 50;
            roadSelection[4] = vertex1.x - 6;
            roadSelection[5] = vertex1.y - 40;
            roadSelection[6] = vertex1.x - 9;
            roadSelection[7] = vertex1.y - 50;
            roadSelection[8] = vertex1.x - 3;
            roadSelection[9] = vertex1.y - 50;
            roadSelection2[0] = vertex2.x + 3;
            roadSelection2[1] = vertex2.y + 50;
            roadSelection2[2] = vertex1.x + 9;
            roadSelection2[3] = vertex1.y - 30;
            roadSelection2[4] = vertex2.x + 6;
            roadSelection2[5] = vertex2.y + 40;
            roadSelection2[6] = vertex2.x + 9;
            roadSelection2[7] = vertex2.y + 50;
            roadSelection2[8] = vertex2.x + 3;
            roadSelection2[9] = vertex2.y + 50;
            roadBounds[0] = vertex1.x - 12;
            roadBounds[1] = vertex2.y + 11;
            roadBounds[2] = vertex2.x + 12;
            roadBounds[3] = vertex1.y - 11;
        }
        if (vertex1.y - vertex2.y == 0 && !vFlippedX) {
            roadSelection[0] = vertex1.x + 30;
            roadSelection[1] = vertex1.y + 3;
            roadSelection[2] = vertex2.x - 50;
            roadSelection[3] = vertex2.y + 9;
            roadSelection[4] = vertex2.x - 40;
            roadSelection[5] = vertex2.y + 6;
            roadSelection[6] = vertex2.x - 50;
            roadSelection[7] = vertex1.y + 3;
            roadSelection[8] = vertex2.x - 50;
            roadSelection[9] = vertex2.y + 9;
            roadSelection2[0] = vertex1.x + 50;
            roadSelection2[1] = vertex1.y - 9;
            roadSelection2[2] = vertex2.x - 30;
            roadSelection2[3] = vertex2.y - 3;
            roadSelection2[4] = vertex1.x + 40;
            roadSelection2[5] = vertex1.y - 6;
            roadSelection2[6] = vertex1.x + 50;
            roadSelection2[7] = vertex1.y - 9;
            roadSelection2[8] = vertex1.x + 50;
            roadSelection2[9] = vertex2.y - 3;
            roadBounds[0] = vertex1.x + 11;
            roadBounds[1] = vertex1.y - 12;
            roadBounds[2] = vertex2.x - 11;
            roadBounds[3] = vertex2.y + 12;
        } else if (vertex1.y - vertex2.y == 0 && vFlippedX) {
            roadSelection[0] = vertex2.x + 30;
            roadSelection[1] = vertex2.y + 3;
            roadSelection[2] = vertex1.x - 50;
            roadSelection[3] = vertex1.y + 9;
            roadSelection[4] = vertex1.x - 40;
            roadSelection[5] = vertex1.y + 6;
            roadSelection[6] = vertex1.x - 50;
            roadSelection[7] = vertex1.y + 3;
            roadSelection[8] = vertex1.x - 50;
            roadSelection[9] = vertex1.y + 9;
            roadSelection2[0] = vertex2.x + 50;
            roadSelection2[1] = vertex2.y - 9;
            roadSelection2[2] = vertex1.x - 30;
            roadSelection2[3] = vertex1.y - 3;
            roadSelection2[4] = vertex2.x + 40;
            roadSelection2[5] = vertex2.y - 6;
            roadSelection2[6] = vertex2.x + 50;
            roadSelection2[7] = vertex2.y - 9;
            roadSelection2[8] = vertex2.x + 50;
            roadSelection2[9] = vertex2.y - 3;
            roadBounds[0] = vertex2.x + 11;
            roadBounds[1] = vertex1.y - 12;
            roadBounds[2] = vertex1.x - 11;
            roadBounds[3] = vertex2.y + 12;
        }
    }
    void drawSelectionEastSouth() {
        // Draw the arrow
        fill(51,206,195);
        rect(roadSelection[0], roadSelection[1], roadSelection[2] - roadSelection[0],
                roadSelection[3] - roadSelection[1]);
        triangle(roadSelection[4], roadSelection[5], roadSelection[6], roadSelection[7],
                roadSelection[8], roadSelection[9]);

        // Draw number denoting how many times the vehicle will drive in that direction
        if (roadSelectedDictionary[cID][0] > 0) {
            fill(0);
            textAlign(LEFT, CENTER);
            if (horizontal) {
                text(roadSelectedDictionary[cID][0].toString(), roadSelection[4]-18, roadSelection[5]+10);
            } else {
                text(roadSelectedDictionary[cID][0].toString(), roadSelection[4]-15, roadSelection[5]-10);
            }
            textAlign(LEFT);
        }
    }
    void drawSelectionWestNorth() {
        // Draw the arrow
        fill(51,206,195);
        rect(roadSelection2[0], roadSelection2[1], roadSelection2[2] - roadSelection2[0],
                roadSelection2[3] - roadSelection2[1]);
        triangle(roadSelection2[4], roadSelection2[5], roadSelection2[6], roadSelection2[7],
                roadSelection2[8], roadSelection2[9]);

        // Draw number denoting how many times the vehicle will drive in that direction
        if (roadSelectedDictionary[cID][1] > 0) {
            fill(0);
            textAlign(LEFT, CENTER);
            if (horizontal) {
                text(roadSelectedDictionary[cID][1].toString(), roadSelection[4]-28, roadSelection[5]-20);
            } else {
                text(roadSelectedDictionary[cID][1].toString(), roadSelection[4]+10, roadSelection[5]-30);
            }
            textAlign(LEFT);
        }
    }
    void draw(float v1x,float v1y,float v2x, float v2y){
        if(debugging)
            stroke(0,0,0);
        line(vertex1.x, vertex1.y, vertex2.x, vertex2.y);

        // If the road has been selected or the mouse is within the road bounds,
        // draw the road highlight in the valid direction
        if (roadSelectedDictionary != null && roadSelectedDictionary[cID][0] > 0) {
            noStroke();
            drawSelectionEastSouth();
            stroke(0);
        }
        if (roadSelectedDictionary != null && roadSelectedDictionary[cID][1] > 0) {
            noStroke();
            drawSelectionWestNorth();
            stroke(0);
        }

        // Render the fraction text next to the road segment and highlight the direction
        // the vehicle will travel in (if the road is adjacent to the vehicle's current location)
        fill(126);
        if (!driveFlag && (mouseOffsetX >= roadBounds[0] && mouseOffsetX <= roadBounds[2] &&
                mouseOffsetY >= roadBounds[1] && mouseOffsetY <= roadBounds[3])) {
            if (futurePosition.x == vertex1.x && futurePosition.y == vertex1.y) {
                noStroke();
                if (!vFlippedX && !vFlippedY) {
                    drawSelectionEastSouth();
                } else if (vFlippedX || vFlippedY) {
                    drawSelectionWestNorth();
                }
                stroke(0);
            } else if (futurePosition.x == vertex2.x && futurePosition.y == vertex2.y) {
                noStroke();
                if (!vFlippedX && !vFlippedY) {
                    drawSelectionWestNorth();
                } else if (vFlippedX || vFlippedY) {
                    drawSelectionEastSouth();
                }
                stroke(0);
            }
            fill(0);
        }
        textAlign(CENTER);
        text(fracText, vertical ? vertex1.x + 12 : ((vertex1.x + vertex2.x) * 0.5),
            horizontal ? vertex1.y - 32 : ((vertex1.y + vertex2.y) * 0.5));
        textAlign(LEFT);
        fill(126);
        if (DISPLAY_SHADOWMAP) image(shadowMap, 0, 0);
    }
}
