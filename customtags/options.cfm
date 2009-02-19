<cfoutput>

<cfset query = caller[attributes.query] /> 

<cfif structKeyExists(attributes, 'default')>
  <option value="">#attributes.default#</option>
</cfif>

<cfloop query="query">
  <option value="#query[attributes.value][query.currentrow]#">
    #query[attributes.display][query.currentrow]#
  </option>
</cfloop>

</cfoutput>
