<cfcomponent extends="supermodel2.model">
	<cffunction name="configure">
		<cfset variables.table_name = "processes" />
		<cfset hasMany('processes', 'supermodel2.tests.position') />
	</cffunction>
</cfcomponent>