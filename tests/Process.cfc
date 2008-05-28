<cfcomponent extends="supermodel.datamodel">
	<cffunction name="configure">
		<cfset variables.table_name = "processes" />
		<cfset variables.group_by_column = 'process_id' />
		<cfset hasMany('supermodel.tests.position') />
	</cffunction>
</cfcomponent>