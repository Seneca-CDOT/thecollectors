function gameLocation(img,labelIn,topleft,bottomRight,points) {
	this.topLeft=topleft; //the map Location of the Location
	this.botRight=bottomRight;
	this.points=points; //the points value of the Location
	this.image=img;
	//this.labelClip=null;
	this.labelText=labelIn;
}
//set the location
gameLocation.prototype.setLoc=function(p,bottomRight) {
	if(p instanceof mapPoint && bottomRight instanceof mapPoint){
	  	this.topLeft=p.clone();
		this.botRight=bottomRight.clone();
	}
};

gameLocation.prototype.setLabel=function(lb) {
	this.labelText = lb;
};

gameLocation.prototype.getLoc=function(){
	return this.topLeft.clone(); //if someone got the actual loc, they could change it, so just return a clone
};

//set the points value of the location
gameLocation.prototype.setPoints=function(n){
	if (n > 0) {
		this.points = n;
	}
	else {
		this.points = -1;
	}
};

//return the location's points value
gameLocation.prototype.getPoints=function(){
	return this.points;
};

//what to do on arrival
gameLocation.prototype.arrived=function() {
	var retVal = this.points;  //return the points value
	this.points = 0; //then set it to 0, so it can't be used again.
	return retVal;		
};

//make a little graphic show up, displaying the points value when the user mouses over
//the location
gameLocation.prototype.onRollOver=function() {
	//this.gotoAndStop(2);
	//mc = _parent.attachMovie("pointsWindow","pointsWin",_parent.getNextHighestDepth(),{_x:_x,_y:_y});
	//mc.setValue(points.toString());
	//labelClip = _parent.attachMovie("locationLabel","locLabel",_parent.getNextHighestDepth(),{_x:_x,_y:_y});
	//labelClip.setValue(labelText);
};

//make the pop-up points display go away
gameLocation.prototype.onRollOut=function() {
	//this.gotoAndStop(1);
	//mc.removeMovieClip();
	//labelClip.removeMovieClip();
};

//shouldn't really be required, but fixes a bug where the pop-up stays around if
//the user mouses over, clicks and holds, then drags out.
gameLocation.prototype.onDragOut=function() {
	//this.gotoAndStop(1);
	//mc.removeMovieClip();
	//labelClip.removeMovieClip();
};