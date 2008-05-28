<cfcomponent extends="supermodel.datamodel">
	<cffunction name="configure">
		<cfset variables.table_name = "positions" />
		<cfset variables.group_by_column = 'position_id' />
		<cfset belongsTo('supermodel.tests.manager') />
		<cfset belongsTo('supermodel.tests.process') />
	</cffunction>
</cfcomponent>