<cfcomponent extends="playableCharacter">

  <cffunction name="configure">
    <cfset super.configure() />
    <cfset table('druids') />
    <cfset belongsTo('god', 'supermodel2.tests.model.god') />
    <cfset property('god_id', 'int') />
    <cfset persist('god_id') />
  </cffunction>

</cfcomponent>
