function vertex(xin, yin) {	
    this.x = Math.round(xin);
    this.y = Math.round(yin);
    this.empty = true;
}

// Returns the distance between pt1 and pt2
function distance(pt1, pt2) {
    var retval = 0;
    if (pt1 instanceof vertex && pt2 instanceof vertex) {
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

vertex.prototype.clone = function() {
    return new vertex(this.x, this.y);
}

// Check if this point equals other point
vertex.prototype.equals = function(other) {
    var retval = false;
    if (other instanceof vertex) {
        if (other.x == this.x && other.y == this.y) {
            retval = true;
        }
    }
    return retval;
}

// Calculate the slope between this point and other point
vertex.prototype.slope = function(other) {
    var xdiff = other.x - this.x;
    var ydiff = -1 * (other.y - this.y);
    return ydiff / xdiff;
}

vertex.prototype.inverse = function() {
    return new vertex(-this.x, -this.y);
}

vertex.prototype.applyRotation = function(angle) {
    if (getType(angle) == "Number") {
        this.x = this.x*Math.cos(angle) - this.y*Math.sin(angle);
        this.y = this.x*Math.sin(angle) + this.y*Math.cos(angle);
    }
}

vertex.prototype.applyOffset = function(offset) {
    if (offset instanceof vertex) {
        this.x += offset.x;
        this.y += offset.y;
    }
}
vertex.prototype.scale=function(factor){
	var rv=new vertex(this.x*factor,this.y*factor);
	return rv;
}