<cfcomponent extends="playablecharacter">
  <cffunction name="configure">
    <cfset super.configure() />

    <cfset variables.table_name = "thieves" />
    <cfset property('arrested', 'boolean') />

  </cffunction>
</cfcomponent>
