function fraction(num,denom) {
    this.numerator = Math.round(num);
    this.denominator = Math.round(denom);
}

fraction.prototype.toString = function() {
    return this.numerator + "/" + this.denominator;
}

fraction.prototype.evaluate = function() {
    return this.numerator / this.denominator;
}
