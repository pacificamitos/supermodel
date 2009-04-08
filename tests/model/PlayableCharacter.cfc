<cfcomponent extends="character">

  <cffunction name="configure" access="public" returntype="void">
    <cfset super.configure() />
    <cfset table('playable_characters') />
    <cfset property('level',    'int') />
    <cfset property('party_id', 'int') />
    <cfset belongsTo('party', 'supermodel2.tests.model.party') /> 
  </cffunction>

</cfcomponent>
