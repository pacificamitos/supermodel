<cfcomponent>
  <cffunction name="get" access="public" returntype="any">
    <cfargument name="name" type="string" required="yes" />

    <cfset var object = createObject('component', application.model_path & arguments.name) />
    <cfset object.init(request.dsn) />
    <cfset set(object) />
    <cfreturn object />
  </cffunction>

  <cffunction name="set" access="public" returntype="void">
    <cfargument name="object" type="supermodel.model" required="yes" />

    <cfset request['data_object'] = arguments.object />
  </cffunction>
</cfcomponent>
