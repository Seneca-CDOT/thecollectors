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

function animateCash() {
  $("#cashAnimDiv").animate({
    opacity: "toggle",
    top: "64px"
  }, 1500, function() {
    // On completion
    $("#cashAnimDiv").hide();
    $("#cashAnimDiv").css("top", "4px");
    $("#cashAnimDiv").css("opacity", 1.0);
  });
}
var divAvailable = true;
function animateCost(costString) {
  var div = divAvailable ? "#cashAnimDiv3" : "#cashAnimDiv4";
  if (div.indexOf("cashAnimDiv3") > -1) {
      document.getElementById("cashAnimElement3").innerHTML = costString;
  } else {
      document.getElementById("cashAnimElement4").innerHTML = costString;
  }
  divAvailable = false;
  $(div).show();

  $(div).animate({
    opacity: "toggle",
    top: "64px"
  }, 1500, function() {
    // On completion
    $(div).hide();
    $(div).css("top", "4px");
    $(div).css("opacity", 1.0);
    if (div.indexOf("cashAnimDiv3") > -1) {
      divAvailable = true;
    }
  });
}
function animateBonus() {
  $("#cashAnimDiv2").delay(400).animate({
    opacity: "toggle",
    top: "64px"
  }, 1500, function() {
    // On completion
    $("#cashAnimDiv2").hide();
    $("#cashAnimDiv2").css("top", "4px");
    $("#cashAnimDiv2").css("opacity", 1.0);
  });
}
function animateBonusText() {
  $("#bonusAnimDiv").animate({
    opacity: "toggle",
    top: "80px"
  }, 1500, function() {
    // On completion
    $("#bonusAnimDiv").hide();
    $("#bonusAnimDiv").css("top", "230px");
    $("#bonusAnimDiv").css("opacity", 1.0);
  });
}
function animateNeedle(timeOut, degrees, current, currentStep) {
  step = degrees / timeOut;
  currentStep = currentStep || current;
  currentStep += step;
  $("#fuelNeedle").css({
    '-webkit-transform' : 'rotate(' + currentStep + 'deg)',
    'transform' : 'rotate(' + currentStep + 'deg)'
  });
  if (currentStep > current + degrees) {
    setTimeout(function() {
      animateNeedle(timeOut, degrees, current, currentStep);
    }, timeOut);
  }
}
/*
function animateHighlight(elementName, indexBreak, currentStep) {
    step = currentStep || 0;
    if (tutorialIndex < indexBreak) {
    if (step % 2 == 0)
        $(elementName).css("border-color", "black");
    else
        $(elementName).css("border-color", "yellow");
    }

    if (step < 9 && tutorialIndex < indexBreak) {
        step++;
        setTimeout(function() {
          animateHighlight(elementName, indexBreak, step);
        }, 150);
    }
}
*/
/*  Not sure if this will be necessary, so leaving it here just in case
$(".inCanvas").css('-moz-user-select','none');
$(".inCanvas").css('-webkit-user-select','none');
$(".inCanvas").css('ms-user-select','none');
$(".inCanvas").css('user-select','none');
*/
$(document).ready(function(){
  $("#tutorialTextDiv").hide();
  $("#legendDiv").hide();
  $("#fractionBoxDiv").hide();
  $("#fractionBonusImg").hide();
  $(".interHUD").hide();
  $(".HUD").hide();
  initTooltips();
  $("#mainMenuWrap").hide();
});
function backToMap() {
  if (GEN_TUTORIAL && tutorialIndex < 26) return;
  if (GEN_TUTORIAL && tutorialIndex == 26) $("#highlightBox").hide();
  $("#fractionBonusImg").hide();
  $("#fractionBoxDiv").hide();
  $("#fractionBackImg").hide();
  $("#numInvalidTooltip").hide();
  $("#denomInvalidTooltip").hide();
  $("#fracSumNum").val("");
  $("#fracSumDenom").val("");
  $("#fuelWrap").show();
  showFractionBox = false;
}
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
  $("#cashText").bind("mouseover",function(event){
    $("#cashTooltip").show();
  });
  $("#cashText").bind("mouseout",function(event){
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
  $("#parcelText").bind("mouseover",function(event){
    $("#parcelTooltip").show();
  });
  $("#parcelText").bind("mouseout",function(event){
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
  /*Numerator input invalid tooltip init*/
  $("#numInvalidTooltip").html(pageText.inputInvalidTooltip);
  $("#numInvalidTooltip").hide();
  /*Denominator input invalid tooltip init*/
  $("#denomInvalidTooltip").html(pageText.inputInvalidTooltip);
  $("#denomInvalidTooltip").hide();
}
