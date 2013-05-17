function car(img, posIn, len, wid, heading){
	if(posIn instanceof mapPoint){
		this.position=posIn;
		this.topLeft=new mapPoint(posIn.x-wid/2,posIn.y-len/2);
		this.botRight=new mapPoint(posIn.x+wid/2,posIn.y+len/2);
		this.offset=posIn;
	}
	if(getType(heading)=="Number")
		this.heading=heading;
	if(getType(len)=="Number")
		this.len=len;
	if(getType(wid)=="Number")
		this.wid=wid;
	this.image=img;
}
car.prototype.translate=function(x,y){
	if(getType(x)=="Number" && getType(y)=="Number"){
		this.topLeft.x+=x;
		this.topLeft.y+=y;
		this.botRight.x+=x;
		this.botRight.y+=y;	
	}
}
car.prototype.rotate=function(angle){
	if (getType(angle)=="Number"){
		this.topLeft.applyOffset(this.offset.inverse());
		this.topLeft.applyRotation(angle);
		this.topLeft.applyOffset(this.offset);
		this.heading+=angle;
	}
}