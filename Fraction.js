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

Function.prototype.method=function(name,func){
	if(!this.prototype[name]){
	  this.prototype[name]=func;
	  return this;
	}
}
/*simplify creation of integer behaviors*/
Number.method('int',function(){
  return Math[this < 0?'ceil':'floor'](this);
});

function GCD(a, b){
  var tmp;
  var quotient;
  var remainder;
  //b must be the smaller number, a the bigger, swap if this is
  //not the case
  if(a < b){
    tmp = a;
    a = b;
    b = tmp;
  }

  quotient = (a/b).int();
  remainder = a%b;
  while(remainder != 0){
    a = b;
    b = remainder;
    quotient = (a/b).int();
    remainder = a%b;
  }
  return b;
}

/*reduces a function to its simplest form*/
Fraction.prototype.reduce = function(){
  var gcd = GCD(this.numerator, this.denominator);
  this.numerator = this.numerator / gcd;
  this.denominator = this.denominator / gcd;
}

/*adds other to Fraction object*/
Fraction.prototype.add = function(other){
  this.numerator = this.numerator*other.denominator + other.numerator*this.denominator;
  this.denominator = this.denominator*other.denominator;
  this.reduce();
}

