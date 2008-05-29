<cfcomponent extends="user">

	<cffunction name="configure" access="private" returntype="void">
		<cfset super.configure() />
		<cfset hasMany('supermodel.tests.process') />
	</cffunction>
	
</cfcomponent>