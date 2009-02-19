<cfcomponent extends="character">

  <cffunction name="configure" access="public" returntype="void">
    <cfset super.configure() />
    <cfset variables.table_name = "playable_characters" />
    <cfset addProperty('level',    'int') />
    <cfset addProperty('party_id', 'int') />
    <cfset belongsTo('party', 'supermodel2.tests.model.party') /> 
  </cffunction>

</cfcomponent>
