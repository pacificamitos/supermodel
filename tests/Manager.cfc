<cfcomponent extends="user">

	<cffunction name="configure" access="private" returntype="void">
		<cfset super.configure() />
		<cfset this.filter_key = 'manager_id' />
		<cfset hasMany('positions', 'supermodel.tests.position') />
		<cfset hasMany('processes', 'supermodel.tests.process') />
	</cffunction>
	
</cfcomponent>