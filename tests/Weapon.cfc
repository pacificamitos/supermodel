<cfcomponent extends="supermodel2.model">
	<cffunction name="configure" access="private" returntype="void">
		<cfset variables.table_name = "users" />
		<cfset belongsTo('user', 'supermodel2.tests.User') />
	</cffunction>
</cfcomponent>