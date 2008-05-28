<cfcomponent extends="user">

	<cffunction name="configure" access="private" returntype="void">
		<cfset super.configure() />
		<cfset variables.group_by_column = 'manager_id' />
		<cfset hasMany('supermodel.tests.process') />
	</cffunction>
	
</cfcomponent>