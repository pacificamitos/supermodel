<cfcomponent extends="playablecharacter">
  <cffunction name="configure">
    <cfset super.configure() />
    <cfset table('mages') />
    <cfset property('school', 'varchar') />
  </cffunction>
</cfcomponent>
