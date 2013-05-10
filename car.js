    function car(graphic, dest) {
        this.cargraphic = graphic;
        this.destination = dest;
        this.speed = 2;
    }

    car.prototype.draw = function() {
        // draw the car with pjs
    }

    car.prototype.driveTo(dest) {
        this.dest = dest;
        // more stuff to do
    }
