<cfcomponent extends="supermodel.DataModel">

<!------------------------------------------------------------------------------------------ configure

	Description:	Carries out the configuration required for this object to act as a SuperModel
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="configure" access="public" returntype="void" output="false">
		<cfset variables.object_path = 'supermodel.examples.user' />
		<cfset variables.object_name = 'user' />
		<cfset variables.table_name = 'users' />
	</cffunction>

</cfcomponent>