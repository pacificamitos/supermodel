<cfcomponent extends="supermodel.datamodel">
	<cffunction name="configure" access="private" returntype="void">
		<cfset variables.table_name = "companies" />
		<cfset hasMany('users', 'supermodel.tests.User') />
	</cffunction>
</cfcomponent>