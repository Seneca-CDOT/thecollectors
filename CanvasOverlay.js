var prevX,prevY;
function bindCanvasOverlay(){ 
  $(".inCanvas").bind("mouseover",function(event){
    prevX = sketch.mouseX;
    prevY = sketch.mouseY;
  });
  $(".inCanvas").bind("contextmenu",function(event){
    $('canvas').focus();
    sketch.changeMousePressed(false, "RIGHT");
    sketch.mouseClicked();
    return false;
  });
  $(".inCanvas").bind("click",function(){
    sketch.changeMousePressed(false, "LEFT");
    sketch.mouseClicked();
  });
  $(".inCanvas").bind("mousedown",function(event){
    $('canvas').focus();
    sketch.changeMousePressed(true, "LEFT");
    sketch.mousePressed();
    return false;
  });
  $(".inCanvas").bind("mouseup",function(event){
    sketch.changeMousePressed(false);
    sketch.mouseReleased();
  });
  $(".inCanvas").bind("mousemove",function(event){
    var dx = event.pageX - prevX;
    var dy = event.pageY - prevY;
    sketch.pmouseX = sketch.mouseX;
    sketch.pmouseY = sketch.mouseY;
    sketch.mouseX += dx;
    sketch.mouseY += dy;
    prevX = event.pageX;
    prevY = event.pageY;
    if(sketch.getMousePressed())
      sketch.mouseDragged();
    else
      sketch.mouseMoved();
  });
}
/*  Not sure if this will be necessary, so leaving it here just in case
$(".inCanvas").css('-moz-user-select','none');
$(".inCanvas").css('-webkit-user-select','none');
$(".inCanvas").css('ms-user-select','none');
$(".inCanvas").css('user-select','none');
*/