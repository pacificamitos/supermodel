<cfif not structKeyExists(attributes, 'title')>
  <cfset attributes['title'] = attributes['text'] />
</cfif>
<cfif not structKeyExists(attributes, 'root')>
  <cfset attributes['root'] = request.path&'index.cfm/' />
</cfif>

<cfoutput>

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">
    <a href="#attributes.root##attributes.path#" title="#attributes.title#">#attributes.text#</a> 
  </cfcase>
</cfswitch>

</cfoutput>
