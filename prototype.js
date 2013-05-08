     
     /*@pjs preload= "assets/car.png,
                     assets/gas.png,
                     assets/fuel.png,
                     assets/points.png
      "*/
    
     int fontsize = 24;
     PImage car;
     PImage gasStation;
     PImage fuel;
     PImage points;
      void setup() {
        size(960,640);
        //size(640,960);
        stroke(0);
        fill(0);
        textFont(createFont("Arial",fontsize));
        car=loadImage("assets/car.png");
        gasStation=loadImage("assets/gas.png");
        fuel=loadImage("assets/fuel.png");
        points=loadImage("assets/points.png");
        noLoop();
      }

      void draw() {
        background(#EAE9B2);
        image(car,width/2-20,height/2-40,50,80);
        image(gasStation,0,0);
        image(fuel,0,520,width/4,120);
        image(points,720,520,width/4,120);
        //String textstring = "inline example";
        //float twidth = textWidth(textstring);
        //text(textstring, (width-twidth)/2, height/2);

      }