<cfcomponent extends="supermodel.datamodel">

  <cffunction name="configure" access="public" returntype="void">

    <cfset variables.table_name = "characters" />
    <!---<cfset hasMany('weapons', "Weapon', 'weapon') /> --->

    <cfset addProperty('name',  'varchar') />

  </cffunction>

</cfcomponent>
