<cfcomponent extends="supermodel.datamodel">
	<cffunction name="configure">
		<cfset variables.table_name = "positions" />
		<cfset belongsTo('supermodel.tests.manager') />
		<cfset belongsTo('supermodel.tests.process') />
	</cffunction>
</cfcomponent>