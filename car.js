function car(img, topLeft, bottomRight, heading){
	this.topLeft=topLeft;
	this.botRight=bottomRight;
	this.image=img;
	this.heading=heading;
}
car.prototype.translate=function(x,y){
	this.topLeft.x+=x;
	this.topLeft.y+=y;
	this.botRight.x+=x;
	this.botRight.y+=y;	
}
car.prototype.rotate=function(angle){
	this.heading+=angle;
}