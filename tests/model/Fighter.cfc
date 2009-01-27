<cfcomponent extends="playablecharacter">
  <cffunction name="configure">
    <cfset super.configure() />
    <cfset variables.table_name = "fighters" />
    <cfset addProperty('style_id', 'int') />
  </cffunction>
</cfcomponent>
