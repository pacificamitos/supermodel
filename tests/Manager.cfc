<cfcomponent extends="user">

	<cffunction name="configure" access="private" returntype="void">
		<cfset super.configure() />
		<cfset this.filter_key = 'manager_id' />
		<cfset hasMany('positions', 'supermodel2.tests.position') />
		<cfset hasMany('processes', 'supermodel2.tests.process') />
	</cffunction>
	
</cfcomponent>