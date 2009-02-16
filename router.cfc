<cfcomponent>
  <cfset init() />

  <cffunction name="init" access="private" returntype="void">
    <cfset variables.routes = arrayNew(1) />
    <cfset variables.named_routes = structNew() />

    <cfset loadRoutes() />
  </cffunction>

	<cffunction name="add" access="public" returntype="void">
    <cfargument name="pattern" type="string" required="yes" />

    <cfset var route = createObject('component', 'route') />
    <cfinvoke component="#route#" method="init" argumentcollection="#arguments#">

		<cfset arrayAppend(routes, route) />

    <cfif structKeyExists(arguments, 'name')>
      <cfset named_routes[arguments.name] = route />
    </cfif>
	</cffunction>

	<cffunction name="route" access="public" returntype="void">
    <cfargument name="targetPage" type="string" required="yes" />

    <cfset var path = "" />
    <cfset var route = "" />
    <cfset var controller = "" />
    <cfset var action = "" />

    <cfif len(cgi.path_info) GT 1>
      <cfset path = right(cgi.path_info, len(cgi.path_info) - 1) />
    </cfif>

    <cfloop from="1" to="#arrayLen(routes)#" index="i">
      <cfset route = routes[i] />

      <cfif route.match(path)> 
        <cfset controller = "egd_billing.controllers.#route.controller()#_controller" />
        <cfset action = route.action() />

        <cfset fillRequest(route.getParams()) />
        <cfinvoke component="#controller#" method="#action#">
        <cfreturn />
      </cfif>
    </cfloop>

    <cfset fillRequest(url) />
    <cfset fillRequest(form) />
    <cfinclude template="#arguments.targetPage#" />
	</cffunction>

	<cffunction name="fillRequest" access="private" returntype="void">
		<cfargument name="structure" type="struct" required="yes" />
		
		<cfloop list="#structKeyList(arguments.structure)#" index="key">
			<cfset structInsert(request, key, arguments.structure[key], true) />
		</cfloop>
	</cffunction>

  <cffunction name="loadRoutes" access="private" returntype="void">
    <!--- Application routes --->
    <cfinclude template="#request.path#routes.cfm" />

    <!--- Default routes --->
    <cfset add(':controller/:action') />
    <cfset add(':controller/:action/:id') />
  </cffunction>
</cfcomponent>
