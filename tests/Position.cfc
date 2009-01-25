<cfcomponent extends="supermodel.datamodel">
	<cffunction name="configure">
		<cfset variables.table_name = "positions" />
		<cfset belongsTo('manager', 'supermodel.tests.manager') />
		<cfset belongsTo('process', 'supermodel.tests.process') />
	</cffunction>
</cfcomponent>