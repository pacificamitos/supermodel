<cfcomponent extends="supermodel.datamodel">
	<cffunction name="configure">
		<cfset variables.table_name = "processes" />
		<cfset hasMany('processes', 'supermodel.tests.position') />
	</cffunction>
</cfcomponent>