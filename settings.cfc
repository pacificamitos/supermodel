<cfcomponent>
  <cffunction name="rootPath" access="private" returntype="string">
    <cfargument name="base_path" default="./" />

    <cfset var actual_path = expandPath(arguments.base_path)>

    <cfif fileExists(expandPath(arguments.base_path & "Application.cfc"))>
      <cfreturn actual_path>
    <cfelseif reFind(".*[/\\].*[/\\].*", actual_path)>
      <cfreturn rootPath("../#arguments.base_path#")>
    <cfelse>
      <cfthrow message="Unable to determine Application Root Path" detail="#actual_path#">
    </cfif>
  </cffunction>

  <cffunction name="environment" access="private" returntype="string">
    <cffile action="read" file="#rootPath()#environment.txt" variable="request.environment">
    <cfreturn trim(request.environment) />
  </cffunction>
</cfcomponent>
