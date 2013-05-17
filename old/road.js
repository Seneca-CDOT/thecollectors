    var ROAD_WIDTH = 12; // Constant for line width 

    function road(p1, p2,frac) {
        this.point1 = p1;
        this.point2 = p2;
        this.fraction = frac;
    }

    road.prototype.draw = function() {
        // draw a line in pjs
    }

    road.prototype.focus = function() {
        // set fraction to full alpha (opaque)
    }

    road.prototype.unfocus = function() {
        // set fraction to be partially translucent
    }
