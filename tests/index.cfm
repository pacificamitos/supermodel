<!---------------------------------- Comprehensive Example -------------------------------------------

	The following represents a typical view page that will test many of the important DataModel 
	functions altogether.
			
----------------------------------------------------------------------------------------------------->

<cfquery name="masterQuery" datasource="supermodel">
	SELECT 
		users.id AS user_id,
		positions.id AS position_id,
		processes.id AS process_id,
		name,
		number,
		title
	FROM users
	JOIN positions
	ON positions.manager_id = users.id
	JOIN processes
	ON processes.id = positions.process_id
</cfquery>

<cfset manager_object = createObject('component','manager') />
<cfset manager_object.init('supermodel') />
<cfset managers = createObject('component', 'supermodel.objectlist') />
<cfset managers.init(manager_object, masterQuery) />

<cfquery name="managers_query" dbtype="query">
	SELECT DISTINCT
		user_id, name
	FROM masterQuery
</cfquery>

<cfquery name="dans_positions" dbtype="query">
	SELECT position_id, title
	FROM masterQuery
	WHERE user_id = 2
</cfquery>

<cfquery name="dans_processes" dbtype="query">
	SELECT process_id, number
	FROM masterQuery
	WHERE user_id = 2
</cfquery>

<cfdump var="#masterQuery#">
<cfdump var="#managers_query#">
<cfdump var="#dans_positions#">
<cfdump var="#dans_processes#">

<cfoutput>

<h1>Managers</h1>

<cfloop condition="#managers.next()#">
	<cfset manager = managers.current() />
	
	<h2>#manager.name#</h2>

	<table>
		<tr>
			<th>Processes</th>
		</tr>
		<cfloop condition="#manager.processes.next()#">
			<cfset process = manager.processes.current() />
			<tr>
				<td>#process.number#</td>
			</tr>
			<cfloop condition="#process.positions.next()#">
				<cfset position = process.positions.current() />
				<tr>
					<td>#positions.title#</td>
				</tr>
			</cfloop>
		</cfloop>
	</table>
</cfloop>

</cfoutput>