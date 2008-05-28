<!---------------------------------- Comprehensive Example -------------------------------------------

	The following represents a typical view page that will test many of the important DataModel 
	functions altogether.
			
----------------------------------------------------------------------------------------------------->

<cfquery name="masterQuery" datasource="supermodel">
	SELECT 
		positions.manager_id,
		positions.process_id,
		positions.id AS position_id,
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

<cfoutput>

<h1>Managers</h1>

<cfloop condition="#managers.next()#">
	<cfset manager = managers.current() />
	
	<h2>#manager.name#</h2>

	<cfloop condition="#manager.processes.next()#">
		<cfset process = manager.processes.current() />
		<p>
			#process.number#
	
			<ul>
				<cfloop condition="#process.positions.next()#">
					<cfset position = process.positions.current() />
					<li>#position.title#</li>
				</cfloop>
			</ul>
		</p>
	</cfloop>
</cfloop>

</cfoutput>