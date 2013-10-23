//Controls for the Main Menu
function initMainMenu(){
	$("#campaignMenu").hide();
	$("#quickplayMenu").hide();
	$("#mainMenuWrap").show();
	$("#mainMenu").show();
}
function initCampaignMenu(){
	$("#mainMenu").hide();
	$("#campaignMenu").show();
}
function initQuickplayMenu(){
	$("#mainMenu").hide();
	$("#quickplayMenu").show();
}
function startQuickplay(){
	sketch.startQuickplay(document.getElementById("quickDiffSelect").selectedIndex+1,
	document.getElementById("quickLevelSelect").selectedIndex+1);
}