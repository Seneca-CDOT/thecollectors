function car(img, posIn, len, wid, heading){
	this.position=posIn;
	this.topLeft=new mapPoint(posIn.x-wid/2,posIn.y-len/2);
	this.botRight=new mapPoint(posIn.x+wid/2,posIn.y+len/2);
	this.image=img;
	this.heading=heading;
	this.len=len;
	this.wid=wid;
	this.offset=posIn;
}
car.prototype.translate=function(x,y){
	this.topLeft.x+=x;
	this.topLeft.y+=y;
	this.botRight.x+=x;
	this.botRight.y+=y;	
}
car.prototype.rotate=function(angle){
	this.topLeft.applyOffset(this.offset.inverse());
	this.topLeft.applyRotation(angle);
	this.topLeft.applyOffset(this.offset);
	this.heading+=angle;
}