<cfcomponent>
  <cfset init() />

  <cffunction name="init" access="private" returntype="void">
    <cfset variables.model_path = request.path & 'model/' />
    <cfset variables.views_path = request.path & 'views/' />
    <cfset variables.controller_path = request.path & 'controllers/' />

    <cfset fillRequest(url) />
    <cfset fillRequest(form) />
  </cffunction>

  <cffunction name="get" access="public" returntype="model">
    <cfargument name="name" type="string" required="yes" />

    <cfset variables.object = createObject('component', model_path & arguments.name) />
    <cfset variables.object.init(request.dsn) />
    <cfreturn variables.object />
  </cffunction>

  <cffunction name="render" access="private" returntype="void">
    <cfargument name="view" type="string" required="yes" />

    <cfset var controller = listLast(getMetaData(this).name, '.') />
    <cfset var folder = left(controller, find('_', controller) - 1) />
    <cfset var path = "#views_path##folder#/#arguments.view#.cfm" />

    <cfinclude template="#path#" />
  </cffunction>

	<cffunction name="fillRequest" access="private" returntype="void">
		<cfargument name="structure" type="struct" required="yes" />
		
		<cfloop list="#structKeyList(arguments.structure)#" index="key">
			<cfset structInsert(request, key, arguments.structure[key], true) />
		</cfloop>
	</cffunction>
</cfcomponent>
