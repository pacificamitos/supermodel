function showhide(id) 
{
	var help_msg = document.getElementById('help_msg_' + id);

	if (help_msg.style.display != "block")
	{
		help_msg.style.display = "block";
	}
	else
	{
		help_msg.style.display = "none";
	}
}

function updateDate (fieldName) {
	var dateField = document.getElementById(fieldName)
	var dayField = document.getElementById(fieldName+'_dd')
	var monthField = document.getElementById(fieldName+'_mm')
	var yearField = document.getElementById(fieldName+'_yyyy')
	var errorDiv = document.getElementById('error_'+fieldName)
	if (yearField.value.length == 2) {
		yearField.value = "20"+yearField.value
	}
	
	if (yearField.value == "" && monthField.value == "" && dayField.value == "") {
		dateField.value = "";
	} else {
		dateField.value = yearField.value + "-" + fmt00(monthField.value) + "-" + fmt00(dayField.value)
	}
}


//updateTime

function updateTime (fieldName) {
	var timeField = document.getElementById(fieldName)
	var hourField = document.getElementById(fieldName+'_hh')
	var minuteField = document.getElementById(fieldName+'_mm')
	timeField.value = (hourField.value == '24' ? '00' : fmt00(hourField.value)) + ":" + fmt00(minuteField.value)
}