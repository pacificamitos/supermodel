<cfcomponent extends="character">

  <cffunction name="configure" access="private" returntype="void">
    <cfset super.configure() />
    <cfset table('gods') />
    <cfset property('power', 'varchar') />
  </cffunction>

</cfcomponent>
