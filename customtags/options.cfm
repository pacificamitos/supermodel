<cfoutput>

<cfset query = caller[attributes.query] /> 

<cfif structKeyExists(attributes, 'default')>
  <option value="">#attributes.default#</option>
</cfif>

<cfloop query="query">
  <cfset selected = "" />
  <cfset current_value = query[attributes.value][query.currentrow] />
  <cfif structKeyExists(request, 'data_object')>
    <cfset object_value = request.data_object[getBaseTagData('cf_select').attributes.id] /> 
    <cfif object_value EQ current_value> 
      <cfset selected = "selected=""selected""" />
    </cfif>
  </cfif>
  <option value="#query[attributes.value][query.currentrow]#" #selected#>
    #query[attributes.display][query.currentrow]#
  </option>
</cfloop>

</cfoutput>
