<cfoutput>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Supermodel Example</title>
</head>

<body>
	<h1>User</h1>
	
	<cfset title = "Hello <font color=""blue"">Bob</font>" />
	<cfoutput>#title#</cfoutput>
	
	<br />
	<cfset title = ReReplace(title, "<[^>]*>", "", "all")>
	<cfoutput>#title#</cfoutput>
		
	<cfset positionService = createObject('component', 'hr_staffing.model.positions.positionService') />
	<cfset position = createObject('component', 'hr_staffing.model.positions.position') />
	<cfset position.configure() />
	<cfset position.init('hr_staffing') />
	<cfset position.read(1) />
	
	<cfset userService = createObject('component', 'hr_staffing.model.users.UserService') />
	<cfset users = userService.getUsers() />
	<cfdump var="#users#">
	
	<!--- 	<cfset position_activities = positionService.getPositionActivities(position) />
	<cfdump var="#position_activities#"> --->
	
<!--- 	<cfset positions = positionService.getPositions() />
	<cfdump var="#positions#">
	 --->
	<!--- <cfset positionService.getTransactions(position) /> --->

</body>
</html>

</cfoutput>