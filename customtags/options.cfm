<cfoutput>

<cfset query = caller[attributes.query] /> 

<cfif structKeyExists(attributes, 'default')>
  <option value="">#attributes.default#</option>
</cfif>

<cfloop query="query">
  <cfset value = evaluate("query.#attributes.value#") />
  <cfset display = evaluate("query.#attributes.display#") />
  <option value="#value#">#display#</option>
</cfloop>

</cfoutput>
