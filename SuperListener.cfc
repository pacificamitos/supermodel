<!--------------------------------------- SuperListener --------------------------------------------

	The purpose of this component is to abstract out some of the very common controller code that our 
  mach-ii listeners will often use to provide CRUD functionality.
	
---------------------------------------------------------------------------------------------------->

<cfcomponent displayname="SuperListener" extends="MachII.framework.Listener">

<!----------------------------------------------------------------------------------------- configure

	Description:	No configuration is done here but the child listeners will be expected to setup
                their data object and gateway in the variables scope.
	
---------------------------------------------------------------------------------------------------->

	<cffunction name="configure" access="public" returntype="void" 
			hint="Configures this listener as part of the Mach-II framework">

    <cfthrow message="configure method must be overridden by a child listener">
  </cffunction>
	
<!-------------------------------------------------------------------------------------- prepareForm

	Description:	Returns a single object
	
---------------------------------------------------------------------------------------------------->

	<cffunction name="prepareForm" access="public" returntype="void">
		<cfargument name="event" type="MachII.framework.Event" required="true" />

    <cfset variables.object.read(event.getArg('id')) />
    <cfset event.setArg(variables.object_name, variables.object) />
		<cfset event.setArg('data_object', variables.object) />
	</cffunction>
	
<!--------------------------------------------------------------------------------------- prepareList

	Description:	Returns a query of all the entities
	
---------------------------------------------------------------------------------------------------->

	<cffunction name="prepareList" access="public" returntype="void">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
		
    <cfset event.setArg(variables.object_name & "s", variables.gateway.select())>
	</cffunction>
	
<!--------------------------------------------------------------------------------------- processForm

	Description:	Validate the form then either create or update the object.
	
---------------------------------------------------------------------------------------------------->

	<cffunction name="processForm" access="public" returntype="void">
		<cfargument name="event" type="MachII.framework.Event" required="true" />
    <cfset variables.object.load(arguments.event.getArgs()) />
		
		<cfif variables.object.valid()>
			<cfset variables.object.save() />
			<cfset announceEvent(variables.success_event) />
		<cfelse>
			<cfset event.setArg(variables.object_name, variables.object) />		
			<cfset announceEvent(variables.failure_event, arguments.event.getArgs()) />
		</cfif>
	</cffunction>
</cfcomponent>