<cfcomponent>
  <cffunction name="init" access="public" returntype="void">
		<cfargument name="pattern" type="string" required="yes">
		<cfargument name="name" type="string" required="no">

    <cfset var param = "" />

    <cfset variables.params = structNew() />

    <cfset variables.pattern = arguments.pattern />

    <cfif structKeyExists(arguments, 'name')>
      <cfset variables.name = arguments.name />
    </cfif>

    <cfloop list="#structKeyList(arguments)#" index="param">
      <cfif not listFindNoCase("pattern,name", param)>
        <cfset structInsert(variables.params, param, arguments[param], true) />
      </cfif>
    </cfloop>
  </cffunction>

  <cffunction name="match" access="public" returntype="boolean">
    <cfargument name="url" type="string" required="yes">

    <cfset var i = 1 />
    <cfset var expected = "" />
    <cfset var found = "" />

    <cfif listLen(pattern, '/') NEQ listLen(arguments.url, '/')>
      <cfreturn false />
    </cfif>

    <cfloop list="#pattern#" index="expected" delimiters="/">
      <cfset found = listGetAt(url, i, '/') /> 

      <cfif found NEQ expected>
        <cfif find(":", expected) EQ 1>
          <cfset params[right(expected, len(expected) - 1)] = found />
        <cfelse>
          <cfreturn />
        </cfif>
      </cfif>

      <cfset i = i + 1 />
    </cfloop>


    <cfreturn structKeyExists(params, 'controller') AND structKeyExists(params, 'action') />
  </cffunction>

  <cffunction name="controller" access="public" returntype="string">
    <cfreturn variables['params']['controller'] />
  </cffunction>

  <cffunction name="action" access="public" returntype="string">
    <cfreturn variables['params']['action'] />
  </cffunction>

  <cffunction name="getParams" access="public" returntype="struct">
    <cfreturn variables.params />
  </cffunction>
</cfcomponent>
