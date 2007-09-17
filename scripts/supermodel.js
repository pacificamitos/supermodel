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