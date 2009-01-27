<cfcomponent extends="playablecharacter">
  <cffunction name="configure">
    <cfset super.configure() />

    <cfset variables.table_name = "thieves" />
    <cfset addProperty('arrested', 'boolean') />

  </cffunction>
</cfcomponent>
