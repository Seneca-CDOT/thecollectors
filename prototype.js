
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
void rotateWrap(rotMat){

    return rotMat;
}
void setup() {
    /* Setup canvas setting */
    size(960,640);
    stroke(0);
    fill(255);
    frameRate(2);

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

    
    var station=new gameLocation(gasStation,"Gas Station",new mapPoint(100,100),new mapPoint(170,160),1234);
    var theCar=new car(carImg,new mapPoint(455,280),80,50,0);
    coordinator.push(theCar);
    coordinator.push(station);
}
void checkHover(objIn){

    if(objIn instanceof gameLocation){
        if(mouseX>objIn.topLeft.x&&mouseX<objIn.botRight.x&&mouseY>objIn.topLeft.y&&mouseY<objIn.botRight.y){
            image(labelImage,objIn.topLeft.x,objIn.botRight.y);
            text(objIn.labelText,objIn.topLeft.x+10,objIn.botRight.y+50);
            image(pointsWindow,objIn.topLeft.x,objIn.topLeft.y-30);
            text(objIn.getPoints(),objIn.topLeft.x+10,objIn.topLeft.y-13)
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
            rotateVal+=0.01;
            rotate(rotateVal);
            tmp.rotate(0.01);
            console.log(tmp.topLeft);
        }else {translate(tmp.topLeft.x,tmp.topLeft.y);}

        image(tmp.image,0,0);//tmp.topLeft.x,tmp.topLeft.y);
        imageMode(CORNER);
        resetMatrix();
        checkHover(tmp);
    }
    console.log(mouseX+","+mouseY);
    image(fuel,0,520,width/4,120);
    image(points,720,520,width/4,120);

}