<cfcomponent extends="supermodel2.model">
	<cffunction name="configure">
		<cfset variables.table_name = "positions" />
		<cfset belongsTo('manager', 'supermodel2.tests.manager') />
		<cfset belongsTo('process', 'supermodel2.tests.process') />
	</cffunction>
</cfcomponent>