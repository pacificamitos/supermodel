<cfcomponent>
  <cfset init() />

  <cffunction name="init" access="private" returntype="void">
    <cfset variables.model_path = request.path & 'model/' />
    <cfset variables.views_path = request.path & 'views/' />
    <cfset variables.controller_path = request.path & 'controllers/' />
    <cfset variables.routes_path = request.path & 'app/' />
  </cffunction>

  <cffunction name="get" access="public" returntype="model">
    <cfargument name="name" type="string" required="yes" />

    <cfif structKeyExists(session, arguments.name)>
      <cfset variables.object = session[arguments.name] />
      <cfset structDelete(session, arguments.name) />
    <cfelse>
      <cfset variables.object = createObject('component', model_path & arguments.name) />
      <cfset variables.object.init(request.dsn) />
    </cfif>

    <cfreturn variables.object />
  </cffunction>

  <cffunction name="render" access="private" returntype="void">
    <cfargument name="view" type="string" required="yes" />
    <cfargument name="layout" type="string" default="main" />

    <cfset var controller_name = listLast(getMetaData(this).name, '.') />
    <cfset var folder_name = left(controller_name, find('_', controller_name) - 1) />

    <cfset content = "#views_path##folder_name#/#arguments.view#.cfm" />
    <cfinclude template="#views_path#layouts/#arguments.layout#.cfm" />
  </cffunction>

  <cffunction name="redirect_to" access="private" returntype="void">
    <cfargument name="action" type="string" required="yes" />

    <cfset var controller_name = listLast(getMetaData(this).name, '.') />
    <cfset var folder_name = left(controller_name, find('_', controller_name) - 1) />

    <cflocation url="#routes_path##folder_name#/#arguments.action#.cfm" addtoken="no" />
  </cffunction>

	<cffunction name="fillRequest" access="private" returntype="void">
		<cfargument name="structure" type="struct" required="yes" />
		
		<cfloop list="#structKeyList(arguments.structure)#" index="key">
			<cfset structInsert(request, key, arguments.structure[key], true) />
		</cfloop>
	</cffunction>
</cfcomponent>
