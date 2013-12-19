function Vertex(xIn, yIn) {
    this.x = Math.round(xIn);
    this.y = Math.round(yIn);
}

// Returns the distance between pt1 and pt2
function distance(pt1, pt2) {
    var retval = 0;
    if (pt1 instanceof Vertex && pt2 instanceof Vertex) {
        if (pt1.x == pt2.x) {
            if (pt1.y == pt2.y) {
                retval = 0;
            } else {
                retval = Math.abs(pt1.y - pt2.y);
            }
        } else {
            if (pt1.y == pt2.y) {
                retval = Math.abs(pt1.x - pt2.x);
            } else {
                // Calculate distance using to the pythagorean theorem
                var d1 = Math.abs(pt1.x - pt2.x);
                var d2 = Math.abs(pt1.y - pt2.y);
                retval = Math.sqrt((d1 * d1) + (d2 * d2));
            }
        }
    } else { retval = -1; }
    return retval;
}

Vertex.prototype.clone = function() {
    return new Vertex(this.x, this.y);
}

// Check if this point equals other point
Vertex.prototype.equals = function(vertex) {
    var retval = false;
    if (vertex instanceof Vertex) {
        if (vertex.x == this.x && vertex.y == this.y) {
            retval = true;
        }
    }
    return retval;
}

// Calculate the slope between this point and other point
Vertex.prototype.slope = function(vertex) {
    var xdiff = vertex.x - this.x;
    var ydiff = -1 * (vertex.y - this.y);
    return ydiff / xdiff;
}
//this slope is used for the map generator, in order to differentiate the direction of lines that are parallel to the x and y axis
Vertex.prototype.extendedSlope = function(vertex) {
    var xdiff = vertex.x - this.x;
    var ydiff = -1 * (vertex.y - this.y);
    var rv;
    if(xdiff == 0){
        if(ydiff>0) rv=1;
        else rv=-1;
    }
    else if(ydiff == 0){
        if(xdiff>0) rv=1;
        else rv=-1;
    }
    else{
        rv=ydiff/xdiff;
    }
    return rv;
}
Vertex.prototype.inverse = function() {
    return new Vertex(-this.x, -this.y);
}

Vertex.prototype.applyRotation = function(angle) {
    if (getType(angle) == "Number") {
        this.x = this.x*Math.cos(angle) - this.y*Math.sin(angle);
        this.y = this.x*Math.sin(angle) + this.y*Math.cos(angle);
    }
}

Vertex.prototype.move = function(offset) {
    if (offset instanceof Vertex) {
        this.x += offset.x;
        this.y += offset.y;
    }
}
Vertex.prototype.scale = function(factor) {
	var rv = new Vertex(this.x*factor, this.y*factor);
	return rv;
}
