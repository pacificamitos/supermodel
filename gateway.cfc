<cfcomponent>
 	<cffunction name="init" access="public" returntype="void">
		<cfargument name="dsn" type="string" required="yes" />

    <cfset variables.dsn = arguments.dsn />
		<cfset configure() />
	</cffunction>

  <cffunction name="configure" access="private" returntype="void">
    <!--- Implemented in child class if needed --->
  </cffunction>

  <cffunction name="list" access="private" returntype="list">
    <cfargument name="component" type="string" required="yes" />
    <cfargument name="query" type="query" required="yes" />

    <cfset var list = createObject('component', 'list') />
    <cfset var object = createObject('component', arguments.component) />
    <cfset object.init(variables.dsn) />
    <cfset list.init(object, query) />

    <cfreturn list />
  </cffunction>
</cfcomponent>
