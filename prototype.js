     
     /*@pjs preload= "assets/car.png,
                     assets/gas.png,
                     assets/fuel.png,
                     assets/points.png,
                     assets/locationLabel.png,
                     assets/pointsWindow.png,
                     assets/pointsWindowBig.png
      "*/

     int fontsize = 24;
     PImage car;
     PImage gasStation;
     PImage fuel;
     PImage points;
     PImage labelImage;
     PImage pointsWindow;
     PImage pointsWindowBig;
     var station;
      void setup() {
        size(960,640);
        //size(640,960);
        stroke(0);
        fill(255);
        textFont(createFont("Arial",fontsize));
        car=loadImage("assets/car.png");
        gasStation=loadImage("assets/gas.png");
        fuel=loadImage("assets/fuel.png");
        points=loadImage("assets/points.png");
        labelImage=loadImage("assets/locationLabel.png");
        pointsWindow=loadImage("assets/pointsWindow.png");
        pointsWindowBig=loadImage("assets/pointsWindowBig.png");
        frameRate(60);
        station=new gameLocation(gasStation,"Gas Station");
        station.setLoc(new mapPoint(100,100),new mapPoint(170,160));
        station.setPoints(1234);
        textSize(12);
        textAlign(LEFT);
      }

      void draw() {
        background(#EAE9B2);
        if(mouseX>station.loc.x&&mouseX<station.botRight.x&&mouseY>station.loc.y&&mouseY<station.botRight.y){
            image(labelImage,station.loc.x,station.botRight.y);
            String temp=station.labelText;
            text(temp,station.loc.x+10,station.botRight.y+50);
            image(pointsWindow,station.loc.x,station.loc.y-30);
            text(station.getPoints(),station.loc.x+10,station.loc.y-13)
        }
        image(car,width/2-20,height/2-40,50,80);
        //image(gasStation,0,0);
        image(fuel,0,520,width/4,120);
        image(points,720,520,width/4,120);
        

        

        //console.log(check.loc);
        image(station.image,station.loc.x, station.loc.y);   
    
        //String textstring = "inline example";
        //float twidth = textWidth(textstring);
        //text(textstring, (width-twidth)/2, height/2);

      }