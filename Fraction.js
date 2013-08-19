function Fraction(num,denom) {
    this.numerator = Math.round(num);
    this.denominator = Math.round(denom);
}

Fraction.prototype.toString = function() {
	if(this.displayNum && this.displayDenom)
		return this.displayNum + "\n—\n" + this.displayDenom;
    return this.numerator + "\n—\n" + this.denominator;
}

Fraction.prototype.evaluate = function() {
    return this.numerator / this.denominator;
}
Fraction.prototype.genAltDisplay = function() {
	var possDisplays = [];
	for (var i = this.numerator; i >= 2; i--) {
		if(this.numerator%i==0 && this.denominator%i==0){
			possDisplays.push(new Fraction(this.numerator/i,this.denominator/i));
		}
	}
	if(possDisplays.length>0){
		var i=rng(0,possDisplays.length-1);
		this.displayNum=possDisplays[i].numerator;
		this.displayDenom=possDisplays[i].denominator;
	}
}