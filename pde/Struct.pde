/**
 *  Handles drawing of all structures.
 */

class Depot extends Interactor {
    var vertex;
    Depot(vert){
        super("Depot");
        setPosition(vert.x, vert.y);
        vertex=vert;
        setStates();
    }
    void setStates(){
        setScale(0.5);
        addState(new State("default",structureFolder+"depot_default.svg"));
    }
}
class Struct extends InputInteractor {
    var vertex, sBox, structObject, delivered;
    var hovering, fuelCaption;
    Struct(vert, _structObject, tankDenominator, costOfFuel) {
        super("Structure");
        setPosition(vert.x, vert.y);
        vertex = vert;
        hovering = false;
        structObject=_structObject;
        setStates();
        sBox = getBoundingBox();
        fuelCaption = "";
        if (structObject.StructType == "fuel_stn") {
            fuelCaption = "Costs $" + costOfFuel.toString() + " per 1/" + tankDenominator.toString();
        }
    }
    void setStates() {
        setScale(0.5);
        delivered = false;
        addState(new State("delivered",structureFolder+structObject.StructType+"_delivered.svg"));
        addState(new State("default",structureFolder+structObject.StructType+".svg"));
    }
    void resetState() {
        delivered = false;
        swapStates(getState("default"));
    }
    void draw(float v1x,float v1y,float v2x, float v2y){
        super.draw(v1x,v1y,v2x,v2y);
        if (!delivered && structObject.visited && structObject.StuctType != "fuel_stn") {
            delivered = true;
            swapStates(getState("delivered"));
        }
        if (structObject.StructType == "fuel_stn") {
            if (refueled && structObject.visited) {
                swapStates(getState("delivered"));
            } else if (!refueled && structObject.visited) {
                structObject.visited = false;
                swapStates(getState("default"));
            }
        }
        if (hovering) {
            noStroke();
            fill(0, 0, 0, 170);
            rect(sBox[0] - 19, sBox[1] - 23, 110, 30);
            if (structObject.StructType == "fuel_stn") {
                rect(sBox[0] - 39, sBox[1] + 60, 150, 30);
            } else {
                rect(sBox[0] - 8, sBox[1] + 60, 90, 30);
            }
            fill(255);
            textAlign(CENTER);
            text(structObject.StructCaption, sBox[0] - 19, sBox[1] - 14, 110, 30);
            if (structObject.StructType == "fuel_stn") {
                text(fuelCaption, sBox[0] - 39, sBox[1] + 68, 150, 30);
            } else {
                text(structObject.visited ? "Delivered" : "$"+structObject.pointsString(),
                        sBox[0] - 8, sBox[1] + 68, 90, 30);
            }
            stroke(0);
            textAlign(LEFT);
        }
    }
    void mouseMoved(int mx, int my) {
        if (!mapScreen) return;

        // The mouse co-ordinates must be offset by the position of the ViewBox
        // for scrolling and zooming to work properly
        var layerCoords = layer.mapCoordinateFromScreen(mx, my);
        mx = layerCoords[0];
        my = layerCoords[1];

        // For detecting if we've hovered over a road
        mouseOffsetX = mx;
        mouseOffsetY = my;

        if (over(mx, my)) {
            if (!player.currentPosition.equals(vertex)) {
                hovering = true;
                setScale(0.7);
            }
        } else if (hovering) {
            hovering = false;
            setScale(0.5);
        }
    }
}
/*
**  Debugging Classes. Remove at release.
 */
class NodeDebug extends Interactor{
    var vertex,flag;
    NodeDebug(vert,flagin){
        super("Node");
        vertex=vert;
        flag=flagin;
    }
    void draw(float v1x,float v1y,float v2x, float v2y){
        pushMatrix();
        //scale(zoomLevel);
        fill(0,0,255);
        if(flag)
            stroke(0,0,255);
        else
            stroke(255,0,0);
        text(flag, vertex.x+4, vertex.y-2);
        //ellipse(vertex.x,vertex.y,8,8);
        popMatrix();
    }
}
