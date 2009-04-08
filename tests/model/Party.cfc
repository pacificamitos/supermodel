<cfcomponent extends="supermodel2.model">
  <cffunction name="configure" access="private" returntype="void">
    <cfset table('parties') />
    <cfset hasMany('characters', 'supermodel2.tests.model.character', 'character') />

    <cfset property('id',   'int') />
    <cfset property('name', 'varchar') />
  </cffunction>

</cfcomponent>
