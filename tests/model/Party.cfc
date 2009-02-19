<cfcomponent extends="supermodel2.model">
  <cffunction name="configure" access="private" returntype="void">
    <cfset variables.table_name = "parties" />
    <cfset hasMany('characters', 'supermodel2.tests.model.character', 'character') />

    <cfset addProperty('id',   'int') />
    <cfset addProperty('name', 'varchar') />
  </cffunction>

</cfcomponent>
