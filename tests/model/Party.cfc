<cfcomponent extends="supermodel.datamodel">
  <cffunction name="configure" access="private" returntype="void">
    <cfset variables.table_name = "parties" />
    <cfset hasMany('characters', 'supermodel.tests.model.character', 'character') />

    <cfset addProperty('id',   'int') />
    <cfset addProperty('name', 'varchar') />
  </cffunction>

</cfcomponent>
