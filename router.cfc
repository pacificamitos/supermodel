<cfcomponent>
  <cfset init() />

  <cffunction name="init" access="private" returntype="void">
    <cfset variables.routes = arrayNew(1) />
    <cfset variables.named_routes = structNew() />
  </cffunction>

	<cffunction name="add" access="public" returntype="void">
    <cfset var route = createObject('component', 'route') />
    <cfinvoke component="#route#" method="init" argumentcollection="#arguments#">

		<cfset arrayAppend(routes, route) />

    <cfif structKeyExists(arguments, 'name')>
      <cfset named_routes[arguments.name] = route />
    </cfif>
	</cffunction>

	<cffunction name="route" access="public" returntype="void">
    <cfargument name="targetPage" type="string" required="yes" />

    <cfset var url = "" />
    <cfset var route = "" />
    <cfset var controller = "" />
    <cfset var action = "" />

    <cfif cgi.path_info NEQ "">
      <cfset url = right(cgi.path_info, len(cgi.path_info) - 1) />
    </cfif>

    <cfset add(':controller/:action') />

    <cfloop from="1" to="#arrayLen(routes)#" index="i">
      <cfset route = routes[i] />

      <cfif route.match(url)> 
        <cfset controller = "egd_billing.controllers.#route.controller()#_controller" />
        <cfset action = route.action() />

        <cfset fillRequest(route.getParams()) />
        <cfset fillRequest(form) />

        <cfinvoke component="#controller#" method="#action#">
        <cfreturn />
      </cfif>
    </cfloop>

    <cfinclude template="#arguments.targetPage#" />
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
