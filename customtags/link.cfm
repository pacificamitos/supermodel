<cfif not structKeyExists(attributes, 'title')>
  <cfset attributes['title'] = attributes['text'] />
</cfif>

<cfoutput>

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
    <a href="#request.path#index.cfm/#attributes.path#" title="#attributes.title#">#attributes.text#</a> 
  </cfcase>
</cfswitch>

</cfoutput>
