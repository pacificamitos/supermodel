/* ------------------------------------------------------------------------------------ isNumeric
 *
 * Description: Returns true if the argument is a number and false otherwise
 *
 * ----------------------------------------------------------------------------------------------
 */

function isNumeric(value) {
	return typeof value != "boolean" && value !== null && !isNaN(+ value);
}

/* -------------------------------------------------------------------------------- stringToTrim
 *
 * Description: Trims whitespace off the front and end of a string
 *
 * ----------------------------------------------------------------------------------------------
 */

function trim(stringToTrim) {
		return stringToTrim.replace(/^\s+|\s+$/g,"");
}

/* ---------------------------------------------------------------------------------------- fmt00
 *
 * Description: Tags a leading 0 onto single digit numbers.  Used for displaying days and months
 *							for date fields.
 *
 * ----------------------------------------------------------------------------------------------
 */

function fmt00(number){
 if (parseInt(number) < 0) var neg = true;
 if (Math.abs(parseInt(number)) < 10){
	number = "0"+ Math.abs(number);
 }
 if (neg) number = "-"+number;
 return number;
}

/* ------------------------------------------------------------------------------- formatCurrency
 *
 * Description: Rounds number to two decimal places and displays it to two decimal places.
 *
 * ----------------------------------------------------------------------------------------------
 */

function formatCurrency(amount)
{
	var i = parseFloat(amount);
	if(isNaN(i)) { i = 0.00; }
	var minus = '';
	if(i < 0) { minus = '-'; }
	i = Math.abs(i);
	i = parseInt((i + .005) * 100);
	i = i / 100;
	s = new String(i);
	if(s.indexOf('.') < 0) { s += '.00'; }
	if(s.indexOf('.') == (s.length - 2)) { s += '0'; }
	s = minus + s;
	return s;
}

/* ----------------------------------------------------------------------------------- jumpField
 *
 * Description: Automatically jumps to next field when field is filled
 *
 * ----------------------------------------------------------------------------------------------
 */


// The key_counter variable tells us how many keys are held down at any given time
// The jumpField function will not jump to the next field if more than one key is being held down
var key_counter = 0
function jfKeyCounter(action) {

	if (action == 'clear') {
		key_counter = 0
	} else if (action == 'up') {
		key_counter--
	} else {
		key_counter++
	}
	
	if (key_counter < 0) {
		key_counter = 0
	}
		
}


function jumpField(e, jumpYesNo, jumpFieldName, nextJumpField, fieldMaxLen) {		
	// Stop user from typing once the value's length is achieved
	document.getElementById(jumpFieldName).maxLength=fieldMaxLen;
	if (jumpYesNo == "yes") {
		// Make sure they pressed a number key
		if (e.keyCode < 48 || ( e.keyCode > 56 && e.keyCode < 96 ) || e.keyCode > 105 || key_counter > 1) 
		{
			jfKeyCounter('up')
			return
		}
		var jumpField = document.getElementById(jumpFieldName)
		var jumpFieldLen = jumpField.value.length;
		
		if (jumpFieldLen >= fieldMaxLen && nextJumpField != 'none') {
			document.getElementById(nextJumpField).focus();
			document.getElementById(nextJumpField).select();
		} 
	}
	jfKeyCounter('up')
}



/* ---------------------------------------------------------------------------------- getURLparam
 *
 * Description: Takes in the name of a URL parameter and returns the value
 *
 * ----------------------------------------------------------------------------------------------
 */
 
function getURLparam( key )
{
	key = key.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
	var regexS = key + "=[^&##]*";
	var regex = new RegExp( regexS );
	var results = regex.exec( window.location.href );
	if( results == null )
		return "";
	else
		return results[1];
}

/* ---------------------------------------------------------------------------------- setURLparam
 *
 * Description: Takes in the name of a URL parameter and sets it to the given value
 *
 * ----------------------------------------------------------------------------------------------
 */

function setURLparam(key, value, old_location) 
{
	var new_location
	if (!old_location) {
		old_location = 	window.location.href
	}

	if (getURLparam(key) != "")
	{
		var regexS = key + "=([^&##]*)"
		var regex = new RegExp( regexS )
		new_location = old_location.replace(regex, key + "=" + value)
	}
	else
	{
		var url_string = /[^##]*/.exec(old_location)
		var anchor_string = /##.*/.exec(old_location)
		
		if (/\?/.test(url_string))
		{			
			new_location = url_string + "&" + key + "=" + value
		}
		else
		{
			new_location = url_string + "?" + key + "=" + value
		}
		
		if (anchor_string)
		{
			new_location = new_location + anchor_string
		}
	}
	return new_location
}

/* ---------------------------------------------------------------------------------- selectYear
 *
 * Description: Refreshes the page with the selected year set as a URL parameter
 *
 * ----------------------------------------------------------------------------------------------
 */
 
function selectYear(selectField) 
{
	var loc = setURLparam("year", selectField.options[selectField.selectedIndex].value)
	if (getURLparam('page') != "") {
		loc = setURLparam("page", 1, loc)
	}
	window.location.href = loc
}


/* ---------------------------------------------------------------------------------- show
 *
 * Description: Sets an element's style to display:block;
 *
 * ----------------------------------------------------------------------------------------------
 */
 
function show(id) 
{
	document.getElementById(id).style.display = 'block';
}

/* ---------------------------------------------------------------------------------- showInline
 *
 * Description: Sets an element's style to display:inline;
 *
 * ----------------------------------------------------------------------------------------------
 */
 
function showInline(id) 
{
	document.getElementById(id).style.display = 'inline';
}


/* ---------------------------------------------------------------------------------- hide
 *
 * Description: Sets an element's style to display:none;
 *
 * ----------------------------------------------------------------------------------------------
 */
 
function hide(id) 
{
	document.getElementById(id).style.display = 'none';
}


/* ---------------------------------------------------------------------------------- showHide
 *
 * Description: hides an element if it is visible and shows it if it is hidden
 *
 * ----------------------------------------------------------------------------------------------
 */

function showHide(id, obj) {
	element = document.getElementById(id)
	if (element.style.display == "none") {
		show(id)
		if(obj)
			obj.style.backgroundImage="url(/egd_billing/images/up_arrow.gif)"
	} else {
		hide(id)
		if(obj)
			obj.style.backgroundImage="url(/egd_billing/images/down_arrow.gif)"
	}
}



/* ---------------------------------------------------------------------------------- showLoading
 *
 * Description: shows "Loading..." image on "Dry Dock Number by Client" report page
 *
 * ----------------------------------------------------------------------------------------------
 */
 
 function showLoading() {
	 document.getElementById('loadingImg').style.display = 'block';
 }