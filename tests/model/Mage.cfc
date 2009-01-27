<cfcomponent extends="playablecharacter">
  <cffunction name="configure">
    <cfset super.configure() />
    <cfset variables.table_name = "mages" />
    <cfset addProperty('school', 'varchar') />
  </cffunction>
</cfcomponent>
