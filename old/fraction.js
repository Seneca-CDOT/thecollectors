function fraction(num,denom){
	if (getType(num)=="Number" && getType(denom)=="Number"){
		this.numerator=num;
		this.denominator=denom;
	}
}
fraction.prototype.toString= function(){
	return this.numerator+"/"+this.denominator;
}
fraction.prototype.evaluate=function(){
	return this.numerator/this.denominator;
}