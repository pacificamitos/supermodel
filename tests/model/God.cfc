<cfcomponent extends="character">

  <cffunction name="configure" access="private" returntype="void">
    <cfset super.configure() />
    <cfset variables.table_name = "gods" />
    <cfset addProperty('power', 'varchar') />
  </cffunction>

</cfcomponent>
