<cfcomponent extends="supermodel2.model">

  <cffunction name="configure" access="public" returntype="void">

    <cfset table('characters') />
    <!---<cfset hasMany('weapons', "Weapon', 'weapon') /> --->

    <cfset property('name',  'varchar') />
    <cfset persist('name') />

  </cffunction>

</cfcomponent>
