function Fraction(num,denom) {
    this.numerator = Math.round(num);
    this.denominator = Math.round(denom);
}

Fraction.prototype.toString = function() {
    return this.numerator + "/" + this.denominator;
}

Fraction.prototype.evaluate = function() {
    return this.numerator / this.denominator;
}
