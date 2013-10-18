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
	document.getElementById("quickDiffSelect").selectedIndex;
	document.getElementById("quickLevelSelect").selectedIndex;
}