<cfcomponent extends="supermodel.datamodel">
	<cffunction name="configure">
		<cfset variables.table_name = "processes" />
		<cfset hasMany('supermodel.tests.position') />
	</cffunction>
</cfcomponent>