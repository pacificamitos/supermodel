//createCal

function createCal(fieldName, anchorName, label) {
	if (window[fieldName+"Calendar"]) {
		return false;
	} else {
		window[fieldName+"Calendar"] = new calendar(fieldName,anchorName,fieldName+"Calendar", label);
	}
}


//updateDate

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


//The calendar object

function calendar(aInput,aAnchor,aSelf,aTitle)
{
	var theDate = "";
	var dd = "";
	var thisDay = "";
	var thisMonth = "";
	var thisYear = "";
	var mm = "";
	var yyyy = "";
	var firstDate = "";
	
	var move = new jWindow(aTitle,175,0,0);
						   
	var self = aSelf;
	var main = move.getMain();
	var bod = move.getBody();
	var an = document.getElementById(aAnchor);
	var input_dd = document.getElementById(aInput+'_dd');
	var input_mm = document.getElementById(aInput+'_mm');
	var input_yyyy = document.getElementById(aInput+'_yyyy');
	var anchorVal = aAnchor;
	
	var dayNameArray = new Array("S","M","T","W","T","F","S");
	
	var monthArray = new Array(31,28,31,30,31,30,31,31,30,31,30,31);
	
	var monthNameArray = new Array("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
	
	an.onclick = startCalendar;
	
	
	
	function startCalendar(e)
	{
		theDate = new Date();
		dd = theDate.getDate();
		thisDay = theDate.getDate();
		mm = theDate.getMonth();
		thisMonth = theDate.getMonth();
		yyyy = theDate.getFullYear();
		thisYear = theDate.getFullYear();
		theDate.setDate(1);
		firstDate = theDate.getDay();
		
		var pos = getMousePosition(e);
		main.style.left = pos.x + "px";
		main.style.top = pos.y + "px";
		move.show();
		
		bod.innerHTML = getCalendar();
		return false;
	}
	
	this.changeMonth = function(key)
	{
		if (key == 0)
		{
			if (mm == 0)
				theDate.setFullYear(yyyy-1, 11);
			else
				theDate.setMonth(mm-1);
		}
		else
		{
			if (mm == 11)
				theDate.setFullYear(yyyy+1, 0);
			else
				theDate.setMonth(mm+1);
		}
		
		dd = theDate.getDate();
		mm = theDate.getMonth();
		yyyy = theDate.getFullYear();
		theDate.setDate(1);
		firstDate = theDate.getDay();
		
		bod.innerHTML = getCalendar();
		
		return false;
	}
	
	this.changeYear = function(key)
	{
		if (key == 0)
			theDate.setFullYear(yyyy-1);
		else
			theDate.setFullYear(yyyy+1);
		
		dd = theDate.getDate();
		mm = theDate.getMonth();
		yyyy = theDate.getFullYear();
		theDate.setDate(1);
		firstDate = theDate.getDay();
		
		bod.innerHTML = getCalendar();
		
		return false;
	}
	
	this.setCalDate = function(year, month, day)
	{
		
		input_dd.value = fmt00(parseInt(day));
		input_mm.value = fmt00(parseInt(month)+1);
		input_yyyy.value =year;

		move.hide();
		input_dd.focus();
		
		if (input_dd.onchange) 
		{
			input_dd.onchange();
			input_mm.onchange();
			input_yyyy.onchange();
		}
			
		return false;
	}
	
	this.resetDate = function()
	{
		theDate = new Date();
		dd = theDate.getDate();
		thisDay = theDate.getDate();
		mm = theDate.getMonth();
		thisMonth = theDate.getMonth();
		yyyy = theDate.getFullYear();
		thisYear = theDate.getFullYear();
		theDate.setDate(1);
		firstDate = theDate.getDay();
		
		bod.innerHTML = getCalendar();
		
		return false;
	}
	
	this.closeCal = function()
	{
		move.hide();

		return false;
	}
	
	function getCalendar()
	{
		var cell ="";
		var call = "";
		
		var string = '<table class="calendar" cellspacing="0"><tr id="calTop">';
		string += '<td colspan="1"><a onclick="' + self + '.changeYear(0)">&lt;</a></td>';
		string += '<td colspan="1"><a onclick="' + self + '.changeMonth(0)">&lt;&lt;</a></td>';
		string += '<td colspan="3">' + monthNameArray[mm] + ' ' + yyyy + '</td>';
		string += '<td colspan="1"><a onclick="' + self + '.changeMonth(1)">&gt;&gt;</a></td>';
		string += '<td colspan="1"><a onclick="' + self + '.changeYear(1)">&gt;</a></td>';
		string += '</td></tr>';
		
		string += '<tr class="calDays">';
		for (i = 0; i <= 6; i++)
			string += '<td>' + dayNameArray[i] + '</td>'
		string += '</tr>';
		
		var dCount = 1;
	
		for (i = 0; i < firstDate; i++)
		{
			cell = ' class="calEmpty"';
				
			if (dCount % 7 == 0)
				string += '<td' + cell + '></td></tr>';
			else if (dCount % 7 == 1)
				string += '<tr><td' + cell + '></td>';
			else
				string += '<td' + cell + '></td>';
				
			dCount++;
		}
		
		for (i = 1; i <= getMonthDays(mm, yyyy); i++)
		{
			if (thisDay == i && thisMonth == mm && thisYear == yyyy)
				cell = ' class="calToday"';
			else
			{
				if (dCount % 2 == 0)
					cell = ' class="evenCell"';
				else
					cell = ' class="oddCell"';
			}
			
			
				
			call = "onclick=\""+self+".setCalDate('"+yyyy+"','"+mm+"','"+i+"')\"";
				
			if (dCount % 7 == 0)
			{
				string += '<td' + cell + '><a ' + call + '>' + i + '</a></td></tr>';
			}
			else if (dCount % 7 == 1)
			{
				string += '<tr><td' + cell + '><a ' + call + '>' + i + '</a></td>';
			}
			else
			{
				string += '<td' + cell + '><a ' + call + '>' + i + '</a></td>';
			}
			
			dCount++;
		}
	
		var remain = 7 - ((dCount - 1) % 7);
		remain = (remain == 7) ? 0 : remain;
		
		for (i = 0; i < remain; i++)
		{
			cell = ' class="calEmpty"';
				
			if (dCount % 7 == 0)
				string += '<td' + cell + '></td></tr>';
			else if (dCount % 7 == 1)
				string += '<tr><td' + cell + '></td>';
			else
				string += '<td' + cell + '></td>';
				
			dCount++;
		}
		
		string += '<tr id="calFooter"><td colspan="3"><a onclick="'+self+'.resetDate();">Reset</a></td>';
		string += '<td></td>';
		string += '<td colspan="3"><a onclick="'+self+'.closeCal();">Close</a></td></tr>';
		string += '</table>';
		
		return string;
	}
	
	function getMonthDays(month, year)
	{
		if (isLeapYear(year))
		{
			if (month == 1)
				return 29;
			else
				return monthArray[month];
		}
		else
			return monthArray[month];
	}
	
	function isLeapYear(year)
	{
		if (year % 4 == 0)
		{
			if (year % 100 == 0)
			{
				if (year % 400 == 0)
					return true;
				else
					return false;
			}
			else
				return true;
		}
		else
			return false;
	}
	
	function getMousePosition(e) 
	{
		var pos = new Object();
		pos.x = 0;
		pos.y = 0;
		
		if (!e) 
			var e = window.event;
		
		if (e.pageX || e.pageY) 	
		{
			pos.x = e.pageX;
			pos.y = e.pageY;
		}
		else if (e.clientX || e.clientY) 	{
			pos.x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
			pos.y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
		}
		return pos;
	}
}
