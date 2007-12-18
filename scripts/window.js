// This controls the zIndex of the window.  Shared by all windows hence it is global
var zIndex = new Object();
zIndex.value = 100;

function jWindow(aTitle,width,posx,posy)
{
	var opened = false;
	
	var topX = 0;
	var topY = 0;
	
	var currX = 0;
	var currY = 0;
	
	var x = 0;
	var y = 0;
	
	var main = document.createElement('div');
	
	var head = document.createElement('div');
	
	var bod = document.createElement('div');
	
	var foot = document.createElement('div');
	
	main.appendChild(head);
	main.appendChild(bod);
	main.appendChild(foot);
	document.body.appendChild(main);
	
	main.style.left = posx + 'px';
	main.style.top = posy + 'px';
	main.style.position = 'absolute';
	main.style.visibility = 'hidden';
	main.style.width = width + 'px';
	main.style.border = "1px solid #ccc";
	main.style.backgroundColor = "#fff";
	main.style.padding = "1px";
	main.style.paddingRight = "3px";
	
	head.style.textAlign = "center";
	head.style.backgroundColor = "#CC3333";
	head.style.border = "1px solid #333";
	head.style.padding = "5px 0px 5px 0px";
	head.style.color = "#fff";
	head.style.fontWeight = "bold";
	head.style.fontSize = "10px";
	head.style.width = "100%";
	
	foot.style.backgroundColor = "#D7E4FF";
	
	head.innerHTML = aTitle;
	
	this.getMain = function()
	{
		return main;
	}
	
	this.getHead = function()
	{
		return head;
	}
	
	this.getBody = function()
	{
		return bod;
	}
	
	this.getFoot = function()
	{
		return foot;
	}
	
	this.setColor = function(color)
	{
		//main.style.border = "1px solid " + color;
		head.style.backgroundColor = color;
	}
	
	this.setFootPadding = function(aInt)
	{
		foot.style.padding = aInt + "px";
	}
	
	this.setBodyPadding = function(aInt)
	{
		bod.style.padding = aInt + "px";
	}
	
	this.setBodyFont = function(aInt,aFamily,aWeight)
	{
		bod.style.fontSize = aInt + "px";
		bod.style.fontFamily = aFamily;
		bod.style.fontWeight = aWeight;
	}
	
	this.setTitle = function(aTitle)
	{
		head.innerHTML = aTitle;
	}
	
	//head.onmouseover = function () { head.style.cursor = "move";}
	/*head.onmousedown = function init(e) {
		if (!e) 
			var e = window.event;

		main.style.zIndex = zIndex.value++;
			
		if (isNaN(parseInt(main.style.left)))
			topX = 0;
		else
			topX = parseInt(main.style.left);
		if (isNaN(parseInt(main.style.top)))
			topY = 0;
		else
			topY = parseInt(main.style.top);
		
		if (e.pageX || e.pageY) 	
		{
			currX = e.pageX;
			currY = e.pageY;
		}
		else if (e.clientX || e.clientY) 	
		{
			currX = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
			currY = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
		}
		
		if (!IE)
            e.preventDefault(); 
		else
		{
    		window.event.cancelBubble = true;
    		window.event.returnValue = false;
		}

		document.onmousemove = function setPos(e) {
			if (!e) 
				var e = window.event;
				
			if (e.pageX || e.pageY) 	
			{
				x = e.pageX;
				y = e.pageY;
			}
			else if (e.clientX || e.clientY) 	
			{
				x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
				y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
			}
			
			if (!IE)
				e.preventDefault(); 
			else
			{
				window.event.cancelBubble = true;
				window.event.returnValue = false;
			}

			
			main.style.left = topX + x - currX + "px";
			main.style.top = topY + y - currY + "px";
		}
		
		main.onmousedown = function () { main.style.zIndex = zIndex.value++; }
		document.onmouseup = function () { document.onmousemove = null; }
	}*/
	
	this.show = function()
	{
		main.style.zIndex = zIndex.value++;
		main.style.visibility = "visible";
		opened = true;
	}
	
	this.hide = function()
	{
		main.style.visibility = "hidden";
		opened = false;
	}
	
	this.isOpen = function()
	{
		return opened;
	}
	
}