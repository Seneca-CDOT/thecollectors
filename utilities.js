//only works for native object types
function getType(obj){
	var tmp=Object.prototype.toString.call(obj);
	return tmp.slice(8,tmp.length-1);
}
//setup of XML Document
function loadXML(filename){
if (window.XMLHttpRequest)
  	{// code for IE7+, Firefox, Chrome, Opera, Safari
  	xmlhttp=new XMLHttpRequest();
  	}
else
  	{// code for IE6, IE5
  	xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  	}
  	
xmlhttp.open("GET",filename,false); //try to change this to true if possible
xmlhttp.send();
xmlDoc=xmlhttp.responseXML;
return xmlDoc;
}
//end of XML Document setup
function rng(min,max){
	return Math.floor(Math.random()*max+1)+min
}
function getDotProduct(dx1, dy1, dx2, dy2) {
    // normalise both vectors
    var l1 = Math.sqrt(dx1*dx1 + dy1*dy1),
          l2 = Math.sqrt(dx2*dx2 + dy2*dy2);
    if (l1==0 || l2==0) return 0;
    dx1 /= l1;
    dy1 /= l1;
    dx2 /= l2;
    dy2 /= l2;
    return dx1*dx2 + dy1*dy2;
}
/**
modified by Dylan Segna from processing script written by
@author Ryan Alexander
*/
// Line Segment Intersection
function segIntersection(x1, y1, x2, y2, x3, y3, x4, y4) 
{ 
  var bx = x2 - x1; 
  var by = y2 - y1; 
  var dx = x4 - x3; 
  var dy = y4 - y3;
  var b_dot_d_perp = bx * dy - by * dx;
  //var check=getDotProduct(bx,by,dx,dy);
    var cx = x3 - x1;
    var cy = y3 - y1;
        //console.log((cx * dy - cy * dx));
  if(b_dot_d_perp != 0){

    var t = (cx * dy - cy * dx) / b_dot_d_perp;
    if(t < 0 || t > 1) {
      return null;
    }
    var u = (cx * by - cy * bx) / b_dot_d_perp;
    if(u < 0 || u > 1) { 
      return null;
    }
    var point={x1:x1, y1:y1, x2:x2, y2:y2, x:x1+t*bx, y:y1+t*by };
  }
  else if((cx * dy - cy * dx)==0){
    var point={x1:x1, y1:y1, x2:x2 , y2:y2 , colinear:true};
  }
  else return null;
  return point;
}