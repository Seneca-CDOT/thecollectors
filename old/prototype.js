
/*@pjs preload= "assets/car.png,
                assets/gas.png,
                assets/fuel.png,
                assets/points.png,
                assets/locationLabel.png,
                assets/pointsWindow.png,
                assets/pointsWindowBig.png
                "
*/
var coordinator= new Array();
int fontsize = 24;
PImage carImg;
PImage gasStation;
PImage fuel;
PImage points;
PImage labelImage;
PImage pointsWindow;
PImage pointsWindowBig;
var rotateVal=0;
    var x=0;
void setup() {
    /* Setup canvas setting */
    size(960,640);
    stroke(0);
    fill(255);
    frameRate(60);

    /* Set Font Setting */
    textFont(createFont("Arial",fontsize));
    textSize(12);
    textAlign(LEFT);


    /* Loading images */
    carImg=loadImage("assets/car.png");
    gasStation=loadImage("assets/gas.png");
    fuel=loadImage("assets/fuel.png");
    points=loadImage("assets/points.png");
    labelImage=loadImage("assets/locationLabel.png");
    pointsWindow=loadImage("assets/pointsWindow.png");
    pointsWindowBig=loadImage("assets/pointsWindowBig.png");
    /*end image loading*/
    var test=new fraction(1,8);
    
    var station=new gameLocation(gasStation,"Gas Station",new mapPoint(100,100),new mapPoint(170,160),1234);
    station.setGasStation(test);
    var theCar=new car(carImg,new mapPoint(455,280),80,50,0);
    coordinator.push(theCar);
    coordinator.push(station);
    
}
void checkHover(objIn){

    if(objIn instanceof gameLocation){
        if(mouseX>objIn.topLeft.x&&mouseX<objIn.botRight.x&&mouseY>objIn.topLeft.y&&mouseY<objIn.botRight.y){
            image(labelImage,objIn.topLeft.x,objIn.botRight.y);
            text(objIn.labelText,objIn.topLeft.x+10,objIn.botRight.y+50);
            if(!objIn.gas){
                image(pointsWindow,objIn.topLeft.x,objIn.topLeft.y-30);
                text(objIn.getPoints(),objIn.topLeft.x+10,objIn.topLeft.y-13)
            }
            else{
                image(pointsWindowBig,objIn.topLeft.x,objIn.topLeft.y-60);
                var tmpString=objIn.getPoints()+" points for\n"+objIn.gasFraction.toString();
                text(tmpString,objIn.topLeft.x+10,objIn.topLeft.y-46);
            }
        }
    }

}
void draw() {
    background(#EAE9B2);

    for (i=0;i<coordinator.length;i++){
        var tmp=coordinator[i];
        

        if(tmp instanceof car){
            translate(tmp.position.x,tmp.position.y);
            imageMode(CENTER);
            if(x!=0){
                rotateVal+=1/60;
                tmp.rotate(1/60);
                rotate(rotateVal);
            }
            else x++;
        }else {translate(tmp.topLeft.x,tmp.topLeft.y);}

        image(tmp.image,0,0);//tmp.topLeft.x,tmp.topLeft.y);
        imageMode(CORNER);
        resetMatrix();
        checkHover(tmp);
    }
    //console.log(mouseX+","+mouseY);
    image(fuel,0,520,width/4,120);
    image(points,720,520,width/4,120);

}