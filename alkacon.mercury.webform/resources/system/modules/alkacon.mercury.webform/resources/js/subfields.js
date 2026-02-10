// stores the currently active sub fields
if (activeWebformSubFields == null) {
	var activeWebformSubFields = new Array();
}

// stores the mapping of parent field name, chosen parent value and sub field set ID
if (webFormSubFieldMappings == null) {
	var webFormSubFieldMappings = new Array();
}

// initializes the visible sub fields
function initWebformSubFields(formID) {
	const form = document.getElementById(formID);
	const fields = form.querySelectorAll("input, select");
	fields.forEach(field => {
    	if (field.dataset.subfields === "true") {
		  toggleWebformSubFields(field);
    	}
  	});
}

// toggles the sub field visibility depending on the field value
function toggleWebformSubFields(inputField) {
	var subIDToShow = getWebFomSubField(inputField.name, inputField.value);
	var activeID = getActiveWebFormSubField(inputField.name);
	if (activeID != "" && subIDToShow != activeID) {
		// deactivate currently active sub fields
		document.getElementById(activeID).style.display = "none";
		toggleDisableWebFormSubFields(activeID, true);
	}
	if (subIDToShow != "") {
		// set to empty String otherwise FF does not display anything...
		document.getElementById(subIDToShow).style.display = "";
		toggleDisableWebFormSubFields(subIDToShow, false);
	}
	setActiveWebformSubField(inputField.name, subIDToShow);
}

// stores the active sub fields for the field name
function setActiveWebformSubField(fieldName, subID) {
	var found = false;
	for (var i = 0; i < activeWebformSubFields.length; i++) {
		if (activeWebformSubFields[i].fieldName == fieldName) {
			// found existing entry, update it
			activeWebformSubFields[i].subID = subID;
			found = true;
			break;
		}
	}
	if (!found && subID != "") {
		// no active item listed for field, create new entry
		var arrIndex = activeWebformSubFields.length;
		activeWebformSubFields[arrIndex] = new Object();
		activeWebformSubFields[arrIndex].fieldName = fieldName;
		activeWebformSubFields[arrIndex].subID = subID;
	}
}

// returns the active sub field ID for the given field
function getActiveWebFormSubField(fieldName) {
	// iterate all active entries
	for (var i = 0; i < activeWebformSubFields.length; i++) {
		if (activeWebformSubFields[i].fieldName == fieldName) {
			// found entry, return currently active sub ID
			return activeWebformSubFields[i].subID;
		}
	}
	// nothing found, return empty String
	return "";
}

// adds a web form sub field mapping
function addWebFormSubFieldMapping(parentFieldName, parentFieldValue, subID) {
	var arrIndex = webFormSubFieldMappings.length;
	webFormSubFieldMappings[arrIndex] = new Object();
	webFormSubFieldMappings[arrIndex].parentFieldName = parentFieldName;
	webFormSubFieldMappings[arrIndex].parentFieldValue = parentFieldValue;
	webFormSubFieldMappings[arrIndex].subID = subID;
	toggleDisableWebFormSubFields(subID, true);
}

// diables/enables subfields depending on their visibility
function toggleDisableWebFormSubFields(subID, disable) {
	const fields = document.getElementById(subID).querySelectorAll("input, select, textarea");
	fields.forEach(field => {
		field.disabled = disable;
	});
}

// returns the sub field ID to activate for the given parent field name and value
function getWebFomSubField(parentFieldName, parentFieldValue) {
	for (var i = 0; i < webFormSubFieldMappings.length; i++) {
		if (webFormSubFieldMappings[i].parentFieldName == parentFieldName
			&& webFormSubFieldMappings[i].parentFieldValue == parentFieldValue) {
			return webFormSubFieldMappings[i].subID;
		}
	}
	return "";
}