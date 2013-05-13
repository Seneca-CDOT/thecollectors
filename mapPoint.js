function mapPoint(xin, yin) {
	if(getType(xin)=="Number" && getType(yin)=="Number"){
		this.x = Math.round(xin);
		this.y = Math.round(yin);
	}
}

//returns the distance between pt1 and pt2
function distance(pt1, pt2) {
  	var retval = 0;
  	if(pt1 instanceof mapPoint && pt2 instanceof mapPoint){
		if (pt1.x == pt2.x) {
	  		if (pt1.y == pt2.y) {
        		retval = 0;
	  		}
	  		else {
				retval = Math.abs(pt1.y - pt2.y);
			}
		}
		else {
			if (pt1.y == pt2.y) {
				retval = Math.abs(pt1.x - pt2.x);
			}
			else {
				//calculate distance using to the pythagorean theorem
				var d1 = Math.abs(pt1.x - pt2.x);
				var d2 = Math.abs(pt1.y - pt2.y);
				retval = Math.sqrt((d1 * d1) + (d2 * d2));
			}
		}
  	}
  	else {retval=-1;}
	return retval;
}
mapPoint.prototype.clone=function(){
	return new mapPoint(this.x,this.y);
}
//check if this point equals other point
mapPoint.prototype.equals = function(other){
  
    var retval = false;
    if(other instanceof mapPoint){
		if (other.x == this.x && other.y == this.y) {
			retval = true;
		}
  	}
	return retval;
};
//calculate the slope between this point and other point
mapPoint.prototype.slope=function(other){
     var xdiff = other.x - this.x;
	var ydiff = -1 * (other.y - this.y);
	return ydiff/xdiff;
}
mapPoint.prototype.inverse=function(){
	return new mapPoint(-this.x,-this.y);
}
mapPoint.prototype.applyRotation=function(angle){
	if(getType(angle)=="Number"){
		this.x=this.x*Math.cos(angle)-this.y*Math.sin(angle);
		this.y=this.x*Math.sin(angle)+this.y*Math.cos(angle);
	}	
}
mapPoint.prototype.applyOffset=function(offset){
	if(offset instanceof mapPoint){		
		this.x+=offset.x;
		this.y+=offset.y;
	}
}