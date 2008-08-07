<cfcomponent extends="supermodel.DataModel">
	<cfproperty name="name" />

<!------------------------------------------------------------------------------------------ configure

	Description:	Carries out the configuration required for this object to act as a SuperModel
			
----------------------------------------------------------------------------------------------------->	
	
	<cffunction name="configure" access="public" returntype="void">
		<cfset variables.table_name = 'companies' />
		<cfset hasMany('supermodel.examples.User') />
	</cffunction>

</cfcomponent>