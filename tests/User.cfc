<cfcomponent extends="supermodel2.model">
	<cffunction name="configure" access="private" returntype="void">
		<cfset variables.table_name = "users" />
		<cfset belongsTo('company', 'supermodel2.tests.Company') />
		<cfset hasMany('weapons', 'supermodel2.tests.Weapon', 'weapon') />
	</cffunction>
</cfcomponent>
