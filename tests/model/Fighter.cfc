<cfcomponent extends="playablecharacter">
  <cffunction name="configure">
    <cfset super.configure() />
    <cfset table('fighters') />
    <cfset property('style_id', 'int') />
  </cffunction>
</cfcomponent>
