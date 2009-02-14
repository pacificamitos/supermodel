<cfcomponent>
  <cfset init() />

  <cffunction name="init" access="private" returntype="void">
    <cfset variables.routes = arrayNew(1) />
  </cffunction>

	<cffunction name="add" access="public" output="false" returntype="void">
		<cfargument name="pattern" type="string" required="yes">
		<cfargument name="name" type="string" required="no">

		<cfset arrayAppend(routes, structCopy(arguments)) />
	</cffunction>

	<cffunction name="route" access="public" returntype="void">
    <cfset var url = right(cgi.path_info, len(cgi.path_info) - 1) />

    <cfset add(':controller/:action') />

    <cfloop from="1" to="#arrayLen(routes)#" index="i">
      <cfset params = structNew() />
      <cfset j = 0 />
      <cfset matches = 0 />
      <cfset pattern = routes[i]['pattern'] />

      <cfloop list="#pattern#" index="param" delimiters="/">
        <cfset j = j + 1 />
        <cfif find(":", param) EQ 1>
          <cfset params[right(param, len(param)- 1)] = listGetAt(url, j, '/') />
          <cfset matches = matches + 1 />
        </cfif>
      </cfloop>

      <cfif matches EQ count(pattern, ':') 
      AND structKeyExists(params, 'controller') 
      AND structKeyExists(params, 'action')>
        <cfset fillRequest(params) />
        <cfset fillRequest(form) />
        <cfinvoke component="egd_billing.controllers.#params['controller']#_controller" method="#params['action']#">
      </cfif>
    </cfloop>
	</cffunction>

	<cffunction name="fillRequest" access="private" returntype="void">
		<cfargument name="structure" type="struct" required="yes" />
		
		<cfloop list="#structKeyList(arguments.structure)#" index="key">
			<cfset structInsert(request, key, arguments.structure[key], true) />
		</cfloop>
	</cffunction>

  <cffunction name="count" access="private" returntype="numeric">
    <cfargument name="string" type="string" required="yes" />
    <cfargument name="char" type="string" required="yes" />

    <cfset var count = 0 />

    <cfloop from="1" to="#len(string)#" index="i">
      <cfif mid(string, i, 1) EQ char>
        <cfset count = count + 1 />
      </cfif>
    </cfloop>

    <cfreturn count />
  </cffunction>
</cfcomponent>
