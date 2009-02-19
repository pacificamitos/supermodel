<cfcomponent extends="playableCharacter">

  <cffunction name="configure">
    <cfset super.configure() />
    <cfset variables.table_name = "druids" />
    <cfset belongsTo('god', 'supermodel2.tests.model.god') />
    <cfset addProperty('god_id', 'int') />
  </cffunction>

</cfcomponent>
