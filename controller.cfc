<cfcomponent>
  <cffunction name="render" access="private" returntype="void">
    <cfargument name="view" type="string" required="yes" />

    <cfset var component = listLast(getMetaData(this).name, '.') />
    <cfset name = left(component, find('_', component) - 1) />
    <cfset path = "#request.path#views/#name#/#arguments.view#.cfm" />

    <cfinclude template="#path#" />
  </cffunction>
</cfcomponent>
