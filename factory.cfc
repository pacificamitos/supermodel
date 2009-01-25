<cfcomponent>
  <cffunction name="init" access="public" returntype="void">
    <cfargument name="path" type="string" required="yes" />

    <cfset variables.model_path = "#path#model/" />
  </cffunction>

  <cffunction name="new" access="public" returntype="any">
    <cfargument name="name" type="string" required="yes" />

    <cfset var record = createObject('component', variables.model_path & arguments.name) />
    <cfset record.init(request.dsn) />
    <cfset set(record) />
    <cfreturn record />
  </cffunction>

  <cffunction name="set" access="public" returntype="void">
    <cfargument name="object" type="supermodel.record" required="yes" />

    <cfset request['data_object'] = arguments.object />
  </cffunction>
</cfcomponent>
