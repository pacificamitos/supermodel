<cfcomponent extends="user">

	<cffunction name="configure" access="private" returntype="void">
		<cfset super.configure() />
		<cfset this.filter_key = 'manager_id' />
		<cfset hasMany('supermodel.tests.position') />
	</cffunction>
	
</cfcomponent>