var xmldoc=loadXML("map.xml");
var map1= new map();

map1.initEdges(xmlDoc);
map1.initNodes(xmlDoc);
//console.log(map1);