function Fraction(num,denom) {
    this.numerator = Math.round(num);
    this.denominator = Math.round(denom);
}

Fraction.prototype.toString = function() {
	if(this.displayNum && this.displayDenom)
		return this.displayNum + "\n-\n" + this.displayDenom;
    return this.numerator + "\n—\n" + this.denominator;
}

Fraction.prototype.evaluate = function() {
    return this.numerator / this.denominator;
}
Fraction.prototype.genAltDisplay = function() {
	console.log(getType(this.numerator), getType(this.denominator));
	if(this.denominator%this.numerator==0){
		var factor = this.denominator/this.numerator;
		this.displayNum=this.numerator/factor;
		this.displayDenom=this.denominator/factor;
	}
}