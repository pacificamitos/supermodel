<cfcomponent extends="user">

	<cffunction name="configure" access="private" returntype="void">
		<cfset super.configure() />
		<cfset hasMany('supermodel.tests.process') />
		<cfset hasMany('supermodel.tests.position') />
	</cffunction>
	
</cfcomponent>