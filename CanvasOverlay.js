var prevX,prevY;
var stopDragging = false;
function bindCanvasOverlay(){ 
  $(".inCanvas").bind("mouseover",function(event){
    stopDragging=false;
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
$(document).ready(function(){
  $("#tutorialTextDiv").hide();
  $("#legendDiv").hide();
  initTooltips();
});
/*Sets up all the tooltips and their functionality*/
function initTooltips(){
  /*Cash tooltip init*/
  $("#cashTooltip").html(pageText.cashTooltip);
  $("#cashImg").bind("mouseover",function(event){
    $("#cashTooltip").show();
  });
  $("#cashImg").bind("mouseout",function(event){
    $("#cashTooltip").hide();
  });
  $("#cashTooltip").hide();
  /*Parcel tooltip init*/
  $("#parcelTooltip").html(pageText.parcelTooltip);
  $("#parcelImg").bind("mouseover",function(event){
    $("#parcelTooltip").show();
  });
  $("#parcelImg").bind("mouseout",function(event){
    $("#parcelTooltip").hide();
  });
  $("#parcelTooltip").hide();
  /*New map tooltip init*/
  $("#newMapTooltip").html(pageText.newMapTooltip);
  $("#newMapButton").bind("mouseover",function(event){
    $("#newMapTooltip").show();
  });
  $("#newMapButton").bind("mouseout",function(event){
    $("#newMapTooltip").hide();
  });  
  $("#newMapTooltip").hide();
  /*Reset tooltip init*/
  $("#resetTooltip").html(pageText.resetTooltip);
  $("#resetButton").bind("mouseover",function(event){
    $("#resetTooltip").show();
  });
  $("#resetButton").bind("mouseout",function(event){
    $("#resetTooltip").hide();
  });
  $("#resetTooltip").hide();
  /*Fuel tooltip init*/
  $("#fuelTooltip").html(pageText.fuelTooltip);
    $("#fuelText").bind("mouseover",function(event){
    $("#fuelTooltip").show();
  });
  $("#fuelText").bind("mouseout",function(event){
    $("#fuelTooltip").hide();
  });
  $("#fuelTooltip").hide();
}
